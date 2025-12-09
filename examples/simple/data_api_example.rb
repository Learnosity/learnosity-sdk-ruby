#!/usr/bin/env ruby
require 'learnosity/sdk/request/data_api'

# Configuration
# XXX: This is a Learnosity Demos consumer; replace it with your own consumer key
consumer_key = 'yis0TYCu7U9V4o7M'
# XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control
consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
domain = 'localhost'

# Initialize DataApi
data_api = Learnosity::Sdk::DataApi.new(
  consumer_key: consumer_key,
  consumer_secret: consumer_secret,
  domain: domain
)

# Security packet
security_packet = {
  'consumer_key' => consumer_key,
  'domain' => domain
}

# Endpoint
endpoint = 'https://data.learnosity.com/v1/itembank/items'

puts "=== Example 1: Single Request ==="
puts

# Make a single request
response = data_api.request(
  endpoint,
  security_packet,
  consumer_secret,
  { 'limit' => 5 },
  'get'
)

puts "Status: #{response.code}"
data = JSON.parse(response.body)
puts "Records: #{data['meta']['records']}"
puts "Items returned: #{data['data'].length}"
puts

puts "=== Example 2: Iterate Through Pages ==="
puts

# Iterate through pages (up to 3 pages)
page_count = 0
data_api.request_iter(
  endpoint,
  security_packet,
  consumer_secret,
  { 'limit' => 5 },
  'get'
).each do |page|
  page_count += 1
  puts "Page #{page_count}: #{page['data'].length} items"
  break if page_count >= 3
end
puts

puts "=== Example 3: Iterate Through Individual Results ==="
puts

# Iterate through individual results (up to 10 items)
item_count = 0
data_api.results_iter(
  endpoint,
  security_packet,
  consumer_secret,
  { 'limit' => 5 },
  'get'
).each do |item|
  item_count += 1
  puts "Item #{item_count}: #{item['reference'] || item['id'] || 'N/A'}"
  break if item_count >= 10
end
puts

puts "Done!"

