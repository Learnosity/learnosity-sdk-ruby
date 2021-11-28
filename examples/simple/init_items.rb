#!/usr/bin/env ruby
require 'learnosity/sdk/request/init'

security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key. Set values in application.rb.
    'consumer_key'   => Rails.configuration.consumer_key,
	'domain'         => 'localhost'
}
# XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control.
# Set values in application.rb.
consumer_secret = Rails.configuration.consumer_secret

items_request = { 'limit' => 50 }

init = Learnosity::Sdk::Request::Init.new(
	'items',
	security_packet,
	consumer_secret,
	items_request
)

puts init.generate
