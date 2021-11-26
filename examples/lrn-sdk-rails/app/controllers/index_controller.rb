require 'learnosity/sdk/request/init' # Learnosity helper.
require 'securerandom'                # Library for generating UUIDs.

class IndexController < ApplicationController
  @@security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key
    'consumer_key'   => Rails.configuration.consumer_key,
    'domain'         => 'localhost'
  }

  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control
  @@consumer_secret = Rails.configuration.consumer_secret

  @@items_request = {
    "user_id" => SecureRandom.uuid,
    "activity_template_id" => "quickstart_examples_activity_template_001",
    "session_id" => SecureRandom.uuid,
    "activity_id" => "quickstart_examples_activity_001",
    "rendering_type" => "assess",
    "type" => "submit_practice",
    "name" => "Items API Quickstart",
    "state" => "initial"
  }

  def index
    @init = Learnosity::Sdk::Request::Init.new(
      'items',
      @@security_packet,
      @@consumer_secret,
      @@items_request
    )
  end
end
