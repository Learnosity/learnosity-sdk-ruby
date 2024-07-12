require 'digest'
require 'json'
require 'openssl'
require 'learnosity/sdk/exceptions'
require 'learnosity/sdk/utils'
require 'learnosity/sdk/version'
require 'sys/uname'

module Learnosity
  module Sdk
    module Request

      class Init
        # XXX: Needs to be public for unit tests
        attr_reader :security_packet, :request_string

        # Keynames that are valid in the security_packet, they are also in
        # the correct order for signature generation.
        @@valid_security_keys = ['consumer_key', 'domain', 'timestamp', 'expires', 'user_id'];

        # Service names that are valid for `$service`
        @@valid_services = ['assess', 'author', 'data', 'events', 'items', 'questions', 'reports', 'authoraide'];

        # Determines if telemetry is enabled
        @@telemetry_enabled = true

        @@signaturePrefix = '$02$'

        def self.enable_telemetry
          @@telemetry_enabled = true
        end

        def self.disable_telemetry
          @@telemetry_enabled = false
        end

        def initialize(service, security_packet, secret, request_packet = nil, action = nil)
          @sign_request_data = false
          @service = service
          @security_packet = security_packet.clone unless security_packet.nil?
          @secret = secret
          @request_packet = request_packet.clone unless request_packet.nil?
          @action = action

          validate

          if @@telemetry_enabled
            add_meta
          end

          set_service_options

          @request_string = generate_request_string
          @security_packet['signature'] = generate_signature
        end

        def generate_signature
          signature_array = []
          @@valid_security_keys.each do |k|
            if @security_packet.include? k
              signature_array.<< @security_packet[k]
            end
          end

          if @sign_request_data and ! @request_string.nil?
            signature_array << @request_string
          end

          unless @action.nil?
            signature_array << @action
          end

          hash_signature(signature_array, @secret)
        end

        def generate(encode = true)
          output = {}

          case @service
          when 'assess', 'author', 'data', 'items', 'reports', 'authoraide'
            output['security'] =  @security_packet

            unless @request_packet.nil?
              output['request'] = @request_packet
            end

            case @service
            when 'data'
              data_output = { 'security' => JSON.generate(output['security']) }

              if output.key?('request')
                data_output['request'] = JSON.generate(output['request'])
              end

              unless @action.nil?
                data_output['action'] = @action
              end

              return data_output

            when 'assess'
              output = output['request']
            end

          when 'questions'
            output = hash_except(@security_packet, 'domain')

            unless @request_packet.nil?
              output = output.merge(@request_packet)
            end

          when 'events'
            output['security'] =  @security_packet
            output['config'] =  @request_packet
          else
            raise Exception, "generate() for #{@service} not implemented"
          end

          unless encode
            return output
          end

          JSON.generate(output)
        end

        protected

        attr_accessor :service, :secret, :request_packet, :action, :sign_request_data
        attr_writer :security_packet, :request_string

        def get_platform
          if Sys::Platform.linux?
            'linux'
          elsif Sys::Platform.windows?
            'win'
          elsif Sys::Platform.mac?
            'darwin'
          else
            Sys::Uname.platform
          end
        end

        def add_meta
          if @request_packet.nil?
            @request_packet = {}
          end

          sdk_metrics = {
            :version => VERSION,
            :lang => 'ruby',
            :lang_version => RUBY_VERSION,
            :platform => get_platform,
            :platform_version => Sys::Uname.release
          }

          if @request_packet.include? 'meta'
            @request_packet['meta'].delete('sdk') if @request_packet['meta'].include? 'sdk'

            @request_packet['meta'][:sdk] = sdk_metrics
          elsif @request_packet.include? :meta
            @request_packet[:meta].delete('sdk') if @request_packet[:meta].include? 'sdk'

            @request_packet[:meta][:sdk] = sdk_metrics
          else
            @request_packet[:meta] = {}

            @request_packet[:meta][:sdk] = sdk_metrics
          end
        end

        def validate
          if @service.nil?
            raise Learnosity::Sdk::ValidationException, 'The `service` argument wasn\'t found or was empty'
          elsif ! @@valid_services.include? @service
            raise Learnosity::Sdk::ValidationException, "The service provided (#{service}) is not valid"
          end

          # XXX we don't do JSON to native object conversion for now, as the PHP SDK does
          if @security_packet.nil? or ! @security_packet.is_a? Hash
            raise Learnosity::Sdk::ValidationException, 'The security packet must be a Hash'
          else
            @security_packet.each do |k, v|
              unless @@valid_security_keys.include? k
                raise ValidationException, "Invalid key found in the security packet: #{k}"
              end
            end

            if @service == 'questions' and ! @security_packet.include? 'user_id'
              raise ValidationException, 'Questions API requires a `user_id` in the security packet'
            end

            unless @security_packet.include? 'timestamp'
              @security_packet['timestamp'] = Time.now.gmtime.strftime('%Y%m%d-%H%m')
            end
          end

          if @secret.nil? or ! @secret.is_a? String
            raise ValidationException, 'The `secret` argument must be a valid string'
          end

          # XXX we don't do JSON to native object conversion for now, as the PHP SDK does
          if ! @request_packet.nil? and ! @request_packet.is_a? Hash
            raise ValidationException, 'The request packet must be a hash'
          end

          if ! @action.nil? and ! @action.is_a? String
            raise ValidationException, 'The `action` argument must be a string'
          end
        end

        def set_service_options
          case @service
          when 'questions'
            # nothing to do
          when 'assess'
            if @request_packet.key?('questionsApiActivity')
              questions_api_activity = @request_packet['questionsApiActivity']

              signature_parts = {}
              signature_parts['consumer_key'] \
                = questions_api_activity['consumer_key'] \
                = @security_packet['consumer_key']

              signature_parts['domain'] = @security_packet['domain'] \
                || questions_api_activity['domain'] \
                || 'assess.learnosity.com'

              signature_parts['timestamp'] \
                = questions_api_activity['timestamp'] \
                = @security_packet['timestamp']

              signature_parts['expires'] = \
                questions_api_activity['expires'] \
                = @security_packet['expires'] if @security_packet.key?('expires')

              signature_parts['user_id'] = \
                questions_api_activity['user_id'] = \
                @security_packet['user_id']

              signature_parts['secret'] = @security_packet['secret']

              # Remove expires attribute if present but nil
              questions_api_activity = hash_except(questions_api_activity, 'expires') if questions_api_activity['expires'].nil?

              @security_packet = signature_parts
              questions_api_activity['signature'] = generate_signature
              @request_packet['questionsApiActivity'] = questions_api_activity
            end
          when 'items', 'reports'
            @sign_request_data = true
            if ! @request_packet.nil? and @request_packet.include? 'user_id' and
                ! @security_packet.include? 'user_id'
              @security_packet['user_id'] = @request_packet['user_id']
            end
          when 'events'
            hashed_users = {}
            @request_packet['users'].each do |k, v|
              hashed_users[k] =  hash_value(k , @secret)
            end
            @request_packet['users'] = hashed_users
          when 'author', 'data', 'authoraide'
            @sign_request_data = true
          else
            raise Exception, "set_service_options() for #{@service} not implemented"
          end
        end

        def generate_request_string
          JSON.generate @request_packet unless request_packet.nil?
        end

        def hash_value(value, secret)

          @@signaturePrefix + OpenSSL::HMAC.hexdigest("SHA256", secret, value)
        end

        def hash_signature(signature_array, secret)
          hash_value(signature_array.join('_'), secret)
        end
      end

    end
  end
end

# vim: sw=2
