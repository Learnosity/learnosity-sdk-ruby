#!/usr/bin/env ruby
require 'net/http'
require 'json'

require 'learnosity/sdk/request/init'

security_packet = {
	# XXX: This is a Learnosity Demos consumer; replace it with your own consumer key
	'consumer_key'   => 'yis0TYCu7U9V4o7M',
	'domain'         => 'localhost'
}
# XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked in in revision control
consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'

sessionsTemplatesUri = URI('https://data.learnosity.com/v1/sessions/templates')
sessionsTemplatesRequest = { 'items' => [ 'dataapiMCQ10' ] }

init = Learnosity::Sdk::Request::Init.new(
	'data',
	security_packet,
	consumer_secret,
	sessionsTemplatesRequest
)

request = init.generate

puts ">>> [#{sessionsTemplatesUri}] #{JSON.generate(request)}"

res = Net::HTTP.post_form(sessionsTemplatesUri, request)

puts "<<< [#{res.code}] #{res.body}"
