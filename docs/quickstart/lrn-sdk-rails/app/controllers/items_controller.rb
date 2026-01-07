require 'learnosity/sdk/request/init' # Learnosity helper.
require 'learnosity/sdk'               # For UUID generation utility.

class ItemsController < ApplicationController
  @@security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key. Set values in application.rb.
    'consumer_key'   => Rails.configuration.consumer_key,
    'domain'         => 'localhost'
  }

  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control
  @@consumer_secret = Rails.configuration.consumer_secret

  @@items_request = {
    "user_id" => Learnosity::Sdk::Uuid.generate,
    "activity_template_id" => "quickstart_examples_activity_template_001",
    "session_id" => Learnosity::Sdk::Uuid.generate,
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
