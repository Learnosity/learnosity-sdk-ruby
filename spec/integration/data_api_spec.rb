require 'spec_helper'
require 'learnosity/sdk/request/data_api'

RSpec.describe 'DataApi Integration Tests' do
  let(:config) do
    {
      consumer_key: 'yis0TYCu7U9V4o7M',
      consumer_secret: '74c5fd430cf1242a527f6223aebd42d30464be22',
      domain: 'localhost'
    }
  end

  describe 'Request signing and formatting' do
    it 'properly signs and formats a Data API request' do
      captured_request = nil

      mock_adapter = lambda do |url, signed_request, headers|
        captured_request = {
          url: url,
          signed_request: signed_request,
          headers: headers
        }

        double('response',
          is_a?: true,
          code: '200',
          body: JSON.generate({
            'meta' => { 'status' => true, 'records' => 0 },
            'data' => []
          })
        )
      end

      data_api = Learnosity::Sdk::Request::DataApi.new(
        config.merge(http_adapter: mock_adapter)
      )

      data_api.request(
        'https://data.learnosity.com/v2023.1.LTS/itembank/items',
        {
          'consumer_key' => config[:consumer_key],
          'domain' => config[:domain]
        },
        config[:consumer_secret],
        {
          'limit' => 5,
          'references' => ['item_1', 'item_2']
        },
        'get'
      )

      # Verify request was captured
      expect(captured_request).not_to be_nil

      # Verify URL
      expect(captured_request[:url]).to eq('https://data.learnosity.com/v2023.1.LTS/itembank/items')

      # Verify headers
      expect(captured_request[:headers]['Content-Type']).to eq('application/x-www-form-urlencoded')
      expect(captured_request[:headers]['X-Learnosity-Consumer']).to eq(config[:consumer_key])
      expect(captured_request[:headers]['X-Learnosity-Action']).to eq('get_/itembank/items')
      expect(captured_request[:headers]['X-Learnosity-SDK']).to match(/^Ruby:/)

      # Verify signed request contains required fields
      expect(captured_request[:signed_request]['security']).to be_a(String)
      expect(captured_request[:signed_request]['request']).to be_a(String)
      expect(captured_request[:signed_request]['action']).to eq('get')

      # Verify security contains signature
      security = JSON.parse(captured_request[:signed_request]['security'])
      expect(security['signature']).to be_a(String)
      # '$02$' is the Learnosity signature format prefix (version 2)
      expect(security['signature']).to start_with('$02$')
    end

    it 'handles different API versions in endpoint' do
      test_cases = [
        {
          endpoint: 'https://data.learnosity.com/v1/itembank/items',
          expected_action: 'get_/itembank/items'
        },
        {
          endpoint: 'https://data.learnosity.com/v2023.1.LTS/itembank/items',
          expected_action: 'get_/itembank/items'
        },
        {
          endpoint: 'https://data.learnosity.com/latest/itembank/items',
          expected_action: 'get_/itembank/items'
        },
        {
          endpoint: 'https://data.learnosity.com/latest-lts/itembank/items',
          expected_action: 'get_/itembank/items'
        }
      ]

      test_cases.each do |test_case|
        captured_action = nil

        mock_adapter = lambda do |_url, _signed_request, headers|
          captured_action = headers['X-Learnosity-Action']

          double('response',
            is_a?: true,
            code: '200',
            body: JSON.generate({ 'meta' => { 'status' => true }, 'data' => [] })
          )
        end

        data_api = Learnosity::Sdk::Request::DataApi.new(
          config.merge(http_adapter: mock_adapter)
        )

        data_api.request(
          test_case[:endpoint],
          { 'consumer_key' => config[:consumer_key], 'domain' => config[:domain] },
          config[:consumer_secret],
          {},
          'get'
        )

        expect(captured_action).to eq(test_case[:expected_action]),
          "Failed for endpoint: #{test_case[:endpoint]}"
      end
    end
  end

  describe 'Export from main module' do
    it 'is accessible via Learnosity::Sdk::DataApi' do
      expect(Learnosity::Sdk::DataApi).to be_a(Class)

      # Should be instantiable
      data_api = Learnosity::Sdk::DataApi.new(
        consumer_key: 'test',
        consumer_secret: 'test',
        domain: 'test.com'
      )

      expect(data_api).to be_a(Learnosity::Sdk::DataApi)
    end
  end
end

# vim: sw=2

