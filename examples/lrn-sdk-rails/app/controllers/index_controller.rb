require 'learnosity/sdk/request/init'
require 'securerandom'

class IndexController < ApplicationController
  @@security_packet = {
    'consumer_key'   => 'yis0TYCu7U9V4o7M',
    'domain'         => 'localhost'
  }
  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked in in revision control
  @@consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
  @@items_request = {
    "activity_id" => "itemsassessdemo",
    "assess_inline" => true,
    "config" => {
      "administration" => {
	"options" => {"show_exit" => true, "show_extend" => true, "show_save" => true},
	"pwd" => "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"
      },
      "configuration" => {
	"fontsize" => "normal",
	"idle_timeout" => {"countdown_time" => 60, "interval" => 300},
	"lazyload" => false,
	"ondiscard_redirect_url" => "itemsapi_assess.php",
	"onsave_redirect_url" => "itemsapi_assess.php",
	"onsubmit_redirect_url" => "itemsapi_assess.php",
	"stylesheet" => "",
	"submit_criteria" => {"type" => "attempted"}
      },
      "ignore_question_attributes" => [""],
      "labelBundle" => {
	"answerMasking" => "Answer Eliminator",
	"colorScheme" => "Colour Scheme",
	"item" => "Question",
	"paletteInstructions" => "Instructions...colour"
      },
      "navigation" => {
	"auto_save" => {"saveIntervalDuration" => 500, "ui" => false},
	"item_count" => {"question_count_option" => false},
	"scroll_to_test" => false,
	"scroll_to_top" => false,
	"scrolling_indicator" => false,
	"show_accessibility" => {
	  "show_colourscheme" => true,
	  "show_fontsize" => true,
	  "show_zoom" => true
	},
	"show_acknowledgements" => true,
	"show_answermasking" => true,
	"show_calculator" => false,
	"show_configuration" => false,
	"show_fullscreencontrol" => true,
	"show_intro" => true,
	"show_itemcount" => true,
	"show_next" => true,
	"show_outro" => true,
	"show_prev" => true,
	"show_progress" => true,
	"show_save" => false,
	"show_submit" => true,
	"show_title" => true,
	"skip_submit_confirmation" => false,
	"toc" => true,
	"transition" => "fade",
	"transition_speed" => 400,
	"warning_on_change" => false
      },
      "subtitle" => "Walter White",
      "time" => {
	"limit_type" => "soft",
	"max_time" => 1500,
	"show_pause" => true,
	"show_time" => true,
	"warning_time" => 120
      },
      "title" => "Demo activity - showcasing question types and assess options",
      "ui_style" => "main"
    },
    "items" => [
      "Demo3",
      "Demo4",
      "accessibility_demo_6",
      "Demo6",
      "Demo7",
      "Demo8",
      "Demo9",
      "Demo10",
      "audioplayer-demo-1"
    ],
    "name" => "Items API demo - assess activity",
    "rendering_type" => "assess",
    "session_id" => SecureRandom.uuid,
    "state" => "initial",
    "type" => "submit_practice",
    "user_id" => "demo_student"
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
