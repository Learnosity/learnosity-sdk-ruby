require 'net/http'
require 'uri'
require 'json'
require 'learnosity/sdk/request/init'
require 'learnosity/sdk/version'

module Learnosity
  module Sdk
    module Request
      # DataApi - Routing layer for Learnosity Data API
      #
      # Provides methods to make HTTP requests to the Data API with automatic
      # signing and pagination support.
      class DataApi
        attr_reader :consumer_key, :consumer_secret, :domain

        # Initialize a new DataApi instance
        #
        # @param options [Hash] Configuration options
        # @option options [String] :consumer_key Learnosity consumer key
        # @option options [String] :consumer_secret Learnosity consumer secret
        # @option options [String] :domain Domain for security packet
        # @option options [Proc] :http_adapter Optional custom HTTP adapter
        def initialize(options = {})
          @consumer_key = options[:consumer_key]
          @consumer_secret = options[:consumer_secret]
          @domain = options[:domain]
          @http_adapter = options[:http_adapter] || method(:default_http_adapter)
        end

        # Make a single request to Data API
        #
        # @param endpoint [String] Full URL to the Data API endpoint
        # @param security_packet [Hash] Security object with consumer_key and domain
        # @param secret [String] Consumer secret
        # @param request_packet [Hash] Request parameters (default: {})
        # @param action [String] Action type: 'get', 'set', 'update', 'delete' (default: 'get')
        # @return [Net::HTTPResponse] HTTP response object
        def request(endpoint, security_packet, secret, request_packet = {}, action = 'get')
          # Generate signed request using SDK
          init = Init.new('data', security_packet, secret, request_packet, action)
          signed_request = init.generate

          # Extract metadata for routing
          consumer = extract_consumer(security_packet)
          derived_action = derive_action(endpoint, action)

          # Prepare headers with routing metadata
          headers = {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'X-Learnosity-Consumer' => consumer,
            'X-Learnosity-Action' => derived_action,
            'X-Learnosity-SDK' => "Ruby:#{Learnosity::Sdk::VERSION}"
          }

          # Make HTTP request using adapter
          @http_adapter.call(endpoint, signed_request, headers)
        end

        # Iterate over pages of results from Data API
        #
        # @param endpoint [String] Full URL to the Data API endpoint
        # @param security_packet [Hash] Security object
        # @param secret [String] Consumer secret
        # @param request_packet [Hash] Request parameters (default: {})
        # @param action [String] Action type (default: 'get')
        # @return [Enumerator] Enumerator yielding pages of results
        def request_iter(endpoint, security_packet, secret, request_packet = {}, action = 'get')
          Enumerator.new do |yielder|
            # Deep copy to avoid mutation
            security = deep_copy(security_packet)
            request_params = deep_copy(request_packet)
            data_end = false

            until data_end
              response = self.request(endpoint, security, secret, request_params, action)
              validate_response(response)

              data = parse_response_body(response)
              validate_response_status(data)

              data_end = !has_more_pages?(data)
              request_params['next'] = data['meta']['next'] if data['meta'] && data['meta']['next']

              yielder << data
            end
          end
        end

        # Iterate over individual results from Data API
        #
        # Automatically handles pagination and yields each individual result
        # from the data array.
        #
        # @param endpoint [String] Full URL to the Data API endpoint
        # @param security_packet [Hash] Security object
        # @param secret [String] Consumer secret
        # @param request_packet [Hash] Request parameters (default: {})
        # @param action [String] Action type (default: 'get')
        # @return [Enumerator] Enumerator yielding individual results
        def results_iter(endpoint, security_packet, secret, request_packet = {}, action = 'get')
          Enumerator.new do |yielder|
            request_iter(endpoint, security_packet, secret, request_packet, action).each do |page|
              if page['data'].is_a?(Hash)
                # If data is a hash (not array), yield key-value pairs
                page['data'].each do |key, value|
                  yielder << { key => value }
                end
              elsif page['data'].is_a?(Array)
                # If data is an array, yield each item
                page['data'].each do |result|
                  yielder << result
                end
              end
            end
          end
        end

        # Extract consumer key from security packet
        def extract_consumer(security_packet)
          security_packet['consumer_key'] || security_packet[:consumer_key] || ''
        end

        # Derive action metadata from endpoint and action
        def derive_action(endpoint, action)
          uri = URI.parse(endpoint)
          path = uri.path.sub(/\/$/, '')

          # Remove version prefix (e.g., /v1, /v2023.1.LTS, /latest)
          path_parts = path.split('/')

          if path_parts.length > 1
            first_segment = path_parts[1].downcase
            version_pattern = /^v[\d.]+(?:\.(lts|preview\d+))?$/
            special_versions = ['latest', 'latest-lts', 'developer']

            if version_pattern.match?(first_segment) || special_versions.include?(first_segment)
              path = '/' + path_parts[2..-1].join('/')
            end
          end

          "#{action}_#{path}"
        end

        private

        # Default HTTP adapter using Net::HTTP
        def default_http_adapter(endpoint, signed_request, headers)
          uri = URI.parse(endpoint)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')

          request = Net::HTTP::Post.new(uri.request_uri, headers)
          request.set_form_data(signed_request)

          http.request(request)
        end

        # Deep copy a hash to avoid mutation
        # Using JSON serialization instead of Marshal for security
        def deep_copy(obj)
          JSON.parse(JSON.generate(obj))
        end

        # Validate HTTP response
        def validate_response(response)
          return if response.is_a?(Net::HTTPSuccess)
          raise "Server returned HTTP status #{response.code}: #{response.body}"
        end

        # Parse response body as JSON
        def parse_response_body(response)
          JSON.parse(response.body)
        rescue JSON::ParserError
          raise "Server returned invalid JSON: #{response.body}"
        end

        # Validate response has successful status
        def validate_response_status(data)
          return if data.dig('meta', 'status') == true
          raise "Server returned unsuccessful status: #{data.to_json}"
        end

        # Check if there are more pages to fetch
        def has_more_pages?(data)
          data['meta'] && data['meta']['next'] && data['data'] && !data['data'].empty?
        end
      end
    end
  end
end

# vim: sw=2

