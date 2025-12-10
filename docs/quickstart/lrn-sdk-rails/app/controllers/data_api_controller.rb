require 'learnosity/sdk/request/data_api'
require 'json'

class DataApiController < ApplicationController
  # rubocop:disable Metrics/CyclomaticComplexity
  # Note: This is a demo/quickstart controller that intentionally demonstrates
  # three different Data API usage patterns (manual iteration, page iteration,
  # and results iteration) with comprehensive error handling for educational purposes.
  def index
    # Initialize DataApi
    data_api = Learnosity::Sdk::Request::DataApi.new(
      consumer_key: Rails.configuration.consumer_key,
      consumer_secret: Rails.configuration.consumer_secret,
      domain: 'localhost'
    )

    # Endpoint and security packet
    itembank_uri = 'https://data.learnosity.com/latest-lts/itembank/items'
    security_packet = {
      'consumer_key' => Rails.configuration.consumer_key,
      'domain' => 'localhost'
    }

    # Get SDK version
    sdk_version = Learnosity::Sdk::VERSION

    # Initialize request metadata
    @request_metadata = {
      endpoint: itembank_uri,
      action: 'get',
      status_code: nil,
      headers: {
        'X-Learnosity-Consumer' => data_api.send(:extract_consumer, security_packet),
        'X-Learnosity-Action' => data_api.send(:derive_action, itembank_uri, 'get'),
        'X-Learnosity-SDK' => "Ruby:#{sdk_version}"
      }
    }

    # Demo 1: Manual iteration (5 items)
    @demo1_output = []
    @demo1_error = nil

    begin
      data_request = { 'limit' => 1 }

      5.times do |i|
        result = data_api.request(
          itembank_uri,
          security_packet,
          Rails.configuration.consumer_secret,
          data_request,
          'get'
        )

        # Capture status code from the first request
        @request_metadata[:status_code] = result.code if i == 0

        response = JSON.parse(result.body)

        if response['data'] && response['data'].length > 0
          item = response['data'][0]
          @demo1_output << {
            number: i + 1,
            reference: item['reference'] || 'N/A',
            status: item['status'] || 'N/A'
          }
        end

        if response['meta'] && response['meta']['next']
          data_request = { 'next' => response['meta']['next'] }
        else
          break
        end
      end
    rescue => e
      @demo1_error = e.message
    end

    # Demo 2: Page iteration (5 pages)
    @demo2_output = []
    @demo2_error = nil

    begin
      data_request = { 'limit' => 1 }
      page_count = 0

      data_api.request_iter(
        itembank_uri,
        security_packet,
        Rails.configuration.consumer_secret,
        data_request,
        'get'
      ).each do |page|
        page_count += 1
        page_data = {
          page_number: page_count,
          item_count: page['data'] ? page['data'].length : 0,
          items: []
        }

        if page['data']
          page['data'].each do |item|
            page_data[:items] << {
              reference: item['reference'] || 'N/A',
              status: item['status'] || 'N/A'
            }
          end
        end

        @demo2_output << page_data
        break if page_count >= 5
      end
    rescue => e
      @demo2_error = e.message
    end

    # Demo 3: Results iteration (5 items)
    @demo3_output = []
    @demo3_error = nil

    begin
      data_request = { 'limit' => 1 }
      result_count = 0

      data_api.results_iter(
        itembank_uri,
        security_packet,
        Rails.configuration.consumer_secret,
        data_request,
        'get'
      ).each do |item|
        result_count += 1
        @demo3_output << {
          number: result_count,
          reference: item['reference'] || 'N/A',
          status: item['status'] || 'N/A',
          json: JSON.pretty_generate(item)[0..500]
        }
        break if result_count >= 5
      end
    rescue => e
      @demo3_error = e.message
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
end

