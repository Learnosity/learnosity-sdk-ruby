require 'spec_helper'
require 'net/http'
require 'json'

RSpec.describe 'Integration Tests' do
  security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key
    'consumer_key'   => 'yis0TYCu7U9V4o7M',
    'domain'         => 'localhost',
  }
  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked in in revision control
  consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'

  TEST_ENV_DOMAIN=''
  TEST_REGION_DOMAIN='.learnosity.com'
  if !ENV['ENV'].nil? && ENV['ENV'] != 'prod'
    TEST_ENV_DOMAIN=".#{ENV['ENV']}"
  elsif !ENV['REGION'].nil?
    TEST_REGION_DOMAIN="#{ENV['REGION']}" # region is of the form -<REGION>.learnosity.com
  end

  if !ENV['VER'].nil?
    TEST_VERSION_PATH="#{ENV['VER']}"
  else
    TEST_VERSION_PATH="v1"
  end

  base_url = "https://data#{TEST_ENV_DOMAIN}#{TEST_REGION_DOMAIN}/#{TEST_VERSION_PATH}"

  context 'Data API' do

    data_request = { 'limit' => 100 }

    it "can retrieve data from #{base_url}" do
	init = Learnosity::Sdk::Request::Init.new(
		'data',
		security_packet,
		consumer_secret,
		data_request
	)

	request = init.generate

	itembankUri = URI("#{base_url}/itembank/items")

	res = Net::HTTP.post_form(itembankUri, request)

	expect(res.code).to eq('200')

	response = JSON.parse(res.body)

	expect(response['meta']['next']).to_not be nil
	expect(response['meta']['records']).to_not be nil
        expect(response['meta']['records']).to be > 0
    end
  end
end

# vim: sw=2
