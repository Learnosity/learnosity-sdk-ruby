require 'learnosity/sdk/request/init' # Learnosity helper.
require 'securerandom'

class ReportsController < ApplicationController

@@security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key. Set values in application.rb.
    'consumer_key'   => Rails.configuration.consumer_key,
    'domain'         => 'localhost',
    'user_id'        => SecureRandom.uuid
  }

  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control
  @@consumer_secret = Rails.configuration.consumer_secret

  @@reports_request = {
                          "reports" => [{
                              "id"=> "session-detail",
                              "type"=> "session-detail-by-item",
                              "user_id"=> "906d564c-39d4-44ba-8ddc-2d44066e2ba9",
                              "session_id"=> "906d564c-39d4-44ba-8ddc-2d44066e2ba9"
                          }]
                      }
  def index
    @init = Learnosity::Sdk::Request::Init.new(
      'reports',
      @@security_packet,
      @@consumer_secret,
      @@reports_request
    )
  end
end
