require 'learnosity/sdk/request/init' # Learnosity helper.
require 'securerandom'

class AuthoraideController < ApplicationController

@@security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key. Set values in application.rb.
    'consumer_key'   => Rails.configuration.consumer_key,
    'domain'         => 'localhost',
  }

  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control
  @@consumer_secret = Rails.configuration.consumer_secret

  @@authoraide_request =  {
          "user"=> {
              "id" => "brianmoser",
              "firstname" => "Test",
              "lastname" => "Test",
              "email" => "test@test.com"
          }
  }

  def index
    @init = Learnosity::Sdk::Request::Init.new(
      'authoraide',
      @@security_packet,
      @@consumer_secret,
      @@authoraide_request
    )
  end
end
