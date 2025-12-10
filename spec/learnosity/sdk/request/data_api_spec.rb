require 'spec_helper'
require 'learnosity/sdk/request/data_api'

RSpec.describe Learnosity::Sdk::Request::DataApi do
  let(:config) do
    {
      consumer_key: 'yis0TYCu7U9V4o7M',
      consumer_secret: '74c5fd430cf1242a527f6223aebd42d30464be22',
      domain: 'localhost'
    }
  end

  let(:security_packet) do
    {
      'consumer_key' => config[:consumer_key],
      'domain' => config[:domain]
    }
  end

  describe '#initialize' do
    it 'creates instance with options' do
      data_api = described_class.new(config)

      expect(data_api.consumer_key).to eq(config[:consumer_key])
      expect(data_api.consumer_secret).to eq(config[:consumer_secret])
      expect(data_api.domain).to eq(config[:domain])
    end

    it 'creates instance without options' do
      data_api = described_class.new

      expect(data_api).to be_a(described_class)
    end
  end

  describe '#extract_consumer' do
    it 'extracts consumer key from security packet with string keys' do
      data_api = described_class.new(config)
      consumer = data_api.send(:extract_consumer, security_packet)

      expect(consumer).to eq(config[:consumer_key])
    end

    it 'extracts consumer key from security packet with symbol keys' do
      data_api = described_class.new(config)
      consumer = data_api.send(:extract_consumer, { consumer_key: config[:consumer_key] })

      expect(consumer).to eq(config[:consumer_key])
    end

    it 'returns empty string if no consumer key' do
      data_api = described_class.new(config)
      consumer = data_api.send(:extract_consumer, {})

      expect(consumer).to eq('')
    end
  end

  describe '#derive_action' do
    it 'derives action from endpoint with version' do
      data_api = described_class.new(config)
      action = data_api.send(:derive_action,
        'https://data.learnosity.com/v2023.1.LTS/itembank/items',
        'get'
      )

      expect(action).to eq('get_/itembank/items')
    end

    it 'derives action from endpoint with latest' do
      data_api = described_class.new(config)
      action = data_api.send(:derive_action,
        'https://data.learnosity.com/latest/itembank/items',
        'get'
      )

      expect(action).to eq('get_/itembank/items')
    end

    it 'derives action from endpoint without version' do
      data_api = described_class.new(config)
      action = data_api.send(:derive_action,
        'https://data.learnosity.com/itembank/items',
        'get'
      )

      expect(action).to eq('get_/itembank/items')
    end

    it 'handles trailing slash' do
      data_api = described_class.new(config)
      action = data_api.send(:derive_action,
        'https://data.learnosity.com/v1/itembank/items/',
        'get'
      )

      expect(action).to eq('get_/itembank/items')
    end

    it 'handles v1 version' do
      data_api = described_class.new(config)
      action = data_api.send(:derive_action,
        'https://data.learnosity.com/v1/itembank/items',
        'get'
      )

      expect(action).to eq('get_/itembank/items')
    end

    it 'handles latest-lts version' do
      data_api = described_class.new(config)
      action = data_api.send(:derive_action,
        'https://data.learnosity.com/latest-lts/itembank/items',
        'get'
      )

      expect(action).to eq('get_/itembank/items')
    end

    it 'handles developer version' do
      data_api = described_class.new(config)
      action = data_api.send(:derive_action,
        'https://data.learnosity.com/developer/itembank/items',
        'get'
      )

      expect(action).to eq('get_/itembank/items')
    end
  end

  describe '#request' do
    it 'makes a request with mock adapter' do
      mock_response = double('response',
        is_a?: true,
        code: '200',
        body: JSON.generate({
          'meta' => { 'status' => true, 'records' => 1 },
          'data' => [{ 'reference' => 'item_1' }]
        })
      )

      mock_adapter = lambda do |url, signed_request, headers|
        expect(url).to eq('https://data.learnosity.com/v1/itembank/items')
        expect(headers['X-Learnosity-Consumer']).to eq(config[:consumer_key])
        expect(headers['X-Learnosity-Action']).to eq('get_/itembank/items')
        expect(headers['X-Learnosity-SDK']).to match(/^Ruby:/)
        expect(signed_request['security']).to be_a(String)
        expect(signed_request['request']).to be_a(String)
        expect(signed_request['action']).to eq('get')

        mock_response
      end

      data_api = described_class.new(config.merge(http_adapter: mock_adapter))
      response = data_api.request(
        'https://data.learnosity.com/v1/itembank/items',
        security_packet,
        config[:consumer_secret],
        { 'limit' => 1 },
        'get'
      )

      expect(response).to eq(mock_response)
      expect(response.code).to eq('200')
      data = JSON.parse(response.body)
      expect(data['meta']['status']).to be true
      expect(data['data'].length).to eq(1)
    end
  end

  describe '#request_iter' do
    it 'iterates through pages' do
      mock_responses = [
        double('response1',
          is_a?: true,
          code: '200',
          body: JSON.generate({
            'meta' => { 'status' => true, 'records' => 2, 'next' => 'page2' },
            'data' => [{ 'id' => 'a' }]
          })
        ),
        double('response2',
          is_a?: true,
          code: '200',
          body: JSON.generate({
            'meta' => { 'status' => true, 'records' => 2 },
            'data' => [{ 'id' => 'b' }]
          })
        )
      ]

      call_count = 0
      mock_adapter = lambda do |_url, _signed_request, _headers|
        response = mock_responses[call_count]
        call_count += 1
        response
      end

      data_api = described_class.new(config.merge(http_adapter: mock_adapter))
      pages = []

      data_api.request_iter(
        'https://data.learnosity.com/v1/itembank/items',
        security_packet,
        config[:consumer_secret],
        {},
        'get'
      ).each do |page|
        pages << page
      end

      expect(pages.length).to eq(2)
      expect(pages[0]['data'][0]['id']).to eq('a')
      expect(pages[1]['data'][0]['id']).to eq('b')
    end

    it 'raises error on HTTP failure' do
      mock_response = double('response',
        is_a?: false,
        code: '500',
        body: 'Internal Server Error'
      )

      mock_adapter = ->(_url, _signed_request, _headers) { mock_response }

      data_api = described_class.new(config.merge(http_adapter: mock_adapter))

      expect {
        data_api.request_iter(
          'https://data.learnosity.com/v1/itembank/items',
          security_packet,
          config[:consumer_secret],
          {},
          'get'
        ).first
      }.to raise_error(/Server returned HTTP status 500/)
    end

    it 'raises error on invalid JSON' do
      mock_response = double('response',
        is_a?: true,
        code: '200',
        body: 'not valid json'
      )

      mock_adapter = ->(_url, _signed_request, _headers) { mock_response }

      data_api = described_class.new(config.merge(http_adapter: mock_adapter))

      expect {
        data_api.request_iter(
          'https://data.learnosity.com/v1/itembank/items',
          security_packet,
          config[:consumer_secret],
          {},
          'get'
        ).first
      }.to raise_error(/Server returned invalid JSON/)
    end

    it 'raises error on unsuccessful status' do
      mock_response = double('response',
        is_a?: true,
        code: '200',
        body: JSON.generate({
          'meta' => { 'status' => false },
          'data' => []
        })
      )

      mock_adapter = ->(_url, _signed_request, _headers) { mock_response }

      data_api = described_class.new(config.merge(http_adapter: mock_adapter))

      expect {
        data_api.request_iter(
          'https://data.learnosity.com/v1/itembank/items',
          security_packet,
          config[:consumer_secret],
          {},
          'get'
        ).first
      }.to raise_error(/Server returned unsuccessful status/)
    end
  end

  describe '#results_iter' do
    it 'iterates through individual results from array data' do
      mock_responses = [
        double('response1',
          is_a?: true,
          code: '200',
          body: JSON.generate({
            'meta' => { 'status' => true, 'records' => 3, 'next' => 'page2' },
            'data' => [{ 'id' => 'a' }, { 'id' => 'b' }]
          })
        ),
        double('response2',
          is_a?: true,
          code: '200',
          body: JSON.generate({
            'meta' => { 'status' => true, 'records' => 3 },
            'data' => [{ 'id' => 'c' }]
          })
        )
      ]

      call_count = 0
      mock_adapter = lambda do |_url, _signed_request, _headers|
        response = mock_responses[call_count]
        call_count += 1
        response
      end

      data_api = described_class.new(config.merge(http_adapter: mock_adapter))
      results = []

      data_api.results_iter(
        'https://data.learnosity.com/v1/itembank/items',
        security_packet,
        config[:consumer_secret],
        {},
        'get'
      ).each do |result|
        results << result
      end

      expect(results.length).to eq(3)
      expect(results[0]['id']).to eq('a')
      expect(results[1]['id']).to eq('b')
      expect(results[2]['id']).to eq('c')
    end

    it 'iterates through individual results from hash data' do
      mock_response = double('response',
        is_a?: true,
        code: '200',
        body: JSON.generate({
          'meta' => { 'status' => true },
          'data' => { 'key1' => 'value1', 'key2' => 'value2' }
        })
      )

      mock_adapter = lambda { |url, signed_request, headers| mock_response }

      data_api = described_class.new(config.merge(http_adapter: mock_adapter))
      results = []

      data_api.results_iter(
        'https://data.learnosity.com/v1/itembank/items',
        security_packet,
        config[:consumer_secret],
        {},
        'get'
      ).each do |result|
        results << result
      end

      expect(results.length).to eq(2)
      expect(results[0]).to eq({ 'key1' => 'value1' })
      expect(results[1]).to eq({ 'key2' => 'value2' })
    end
  end
end

# vim: sw=2

