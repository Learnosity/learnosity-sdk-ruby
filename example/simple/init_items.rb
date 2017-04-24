#!/usr/bin/env ruby
require 'learnosity/sdk/request/init'

security_packet = {
	'consumer_key'   => 'yis0TYCu7U9V4o7M',
	'domain'         => 'localhost'
}
# XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked in in revision control
consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
items_request = { 'limit' => 50 }

init = Learnosity::Sdk::Request::Init.new(
	'items',
	security_packet,
	consumer_secret,
	items_request
)

puts init.generate
