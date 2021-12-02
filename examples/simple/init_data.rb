#!/usr/bin/env ruby
require 'net/http'
require 'json'

require 'learnosity/sdk/request/init'

itembank_uri = URI('https://data.learnosity.com/v1/itembank/items')

security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key. Set values in application.rb.
    'consumer_key'   => Rails.configuration.consumer_key,
	'domain'         => 'localhost'
}
# XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control.
# Set values in application.rb.
consumer_secret = Rails.configuration.consumer_secret

data_request = { 'limit' => 1 }

# Do 5 subsequent requests using the `next` pointer
[1,2,3,4,5].each do |reqno|
	init = Learnosity::Sdk::Request::Init.new(
		'data',
		security_packet,
		consumer_secret,
		data_request
	)

	request = init.generate

	puts ">>> [#{itembank_uri} (#{reqno})] #{JSON.generate(request)}"

	res = Net::HTTP.post_form(itembank_uri, request)

	puts "<<< [#{res.code}] #{res.body}"

	response = JSON.parse(res.body)
	if !response['meta']['next'].nil? \
			and !response['meta']['records'].nil? and response['meta']['records'] > 0
		data_request['next'] = response['meta']['next']
	end
end
