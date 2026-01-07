#!/usr/bin/env ruby
require 'bundler/setup'
require 'learnosity/sdk'

# Example: Generate UUIDs using the Learnosity SDK utility
# This is commonly used for user_id and session_id in API requests

puts "Generating UUIDs using Learnosity::Sdk::Uuid.generate:"
puts

# Generate a few UUIDs
5.times do |i|
  uuid = Learnosity::Sdk::Uuid.generate
  puts "UUID #{i + 1}: #{uuid}"
end

puts
puts "Example usage in API requests:"
puts

# Example: Using UUIDs in an Items API request
user_id = Learnosity::Sdk::Uuid.generate
session_id = Learnosity::Sdk::Uuid.generate

puts "user_id: #{user_id}"
puts "session_id: #{session_id}"

# vim: sw=2

