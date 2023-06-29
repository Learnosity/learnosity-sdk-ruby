require 'learnosity/sdk/request/init' # Learnosity helper.
require 'securerandom'

class QuestionsController < ApplicationController

@@security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key. Set values in application.rb.
    'consumer_key'   => Rails.configuration.consumer_key,
    'domain'         => 'localhost',
    'user_id'        => SecureRandom.uuid
  }

  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control
  @@consumer_secret = Rails.configuration.consumer_secret

  @@questions_request = {
                        "id"=> "f0001",
                        "name"=> "Intro Activity - French 101",
                        "questions"=>[
                             {
                                 "response_id"=> "60005",
                                 "type"=> "association",
                                 "stimulus"=> "Match the cities to the parent nation.",
                                 "stimulus_list"=>["London", "Dublin", "Paris", "Sydney"],
                                 "possible_responses"=>["Australia", "France", "Ireland", "England"
                                 ],
                                 "validation"=> {
                                    "valid_responses"=> [
                                        ["England"],["Ireland"],["France"],["Australia"]
                                    ]
                                },
                                "instant_feedback" => true
                            }
                        ],
                    }
  def index
    @init = Learnosity::Sdk::Request::Init.new(
      'questions',
      @@security_packet,
      @@consumer_secret,
      @@questions_request
    )
  end
end
