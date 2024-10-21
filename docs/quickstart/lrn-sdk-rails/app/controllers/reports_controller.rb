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
                              "user_id"=> "student_0001",
                              "session_id"=> "ef4f80b8-e281-41f4-9efd-349b7eb9dd37"
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
