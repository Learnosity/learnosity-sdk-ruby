require 'learnosity/sdk/request/init' # Learnosity helper.
require 'securerandom'

class AuthorController < ApplicationController

@@security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key. Set values in application.rb.
    'consumer_key'   => Rails.configuration.consumer_key,
    'domain'         => 'localhost',
    'user_id'        => SecureRandom.uuid
  }

  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked into version control
  @@consumer_secret = Rails.configuration.consumer_secret

  @@author_request =  {
          "mode"=> "item_edit",
          "reference"=> "a15ac409-f6d5-42de-a491-a1e4ab03c826",
          "user"=> {
              "id" => "brianmoser",
              "firstname" => "Test",
              "lastname" => "Test",
              "email" => "test@test.com"
          },
          "config"=> {
              "global"=> {
                  "disable_onbeforeunload"=> true,
                  "hide_tags"=>
                  [
                    {
                      "type"=> "internal_category_uuid"
                    }
                  ]
              },
              "item_edit"=> {
                  "item"=> {
                      "back"=> true,
                      "columns"=> true,
                      "answers"=> true,
                      "scoring"=> true,
                      "reference"=> {
                          "edit"=> false,
                          "show"=> false,
                          "prefix"=> "LEAR_"
                      },
                      "save"=> true,
                      "status"=> false,
                      "dynamic_content"=> true,
                      "shared_passage"=> true
                  },
                  "widget"=> {
                      "delete"=> false,
                      "edit"=> true
                  }
              },
              "item_list"=> {
                  "item"=> {
                      "status"=> true,
                      "url"=> "http://myApp.com/items/:reference/edit"
                  },
                  "toolbar"=> {
                      "add"=> true,
                      "browse"=> {
                        "controls"=> [
                          {
                            "type"=> "hierarchy",
                            "hierarchies"=> [
                              {
                                "reference"=> "CCSS_Math_Hierarchy",
                                "label"=> "CCSS Math"
                              },
                              {
                                "reference"=> "CCSS_ELA_Hierarchy",
                                "label"=> "CCSS ELA"
                              },
                              {
                                "reference"=> "Demo_Items_Hierarchy",
                                "label"=> "Demo Items"
                              }
                            ]
                          },
                          {
                            "type"=> "tag",
                            "tag"=> {
                               "type"=> "Alignment",
                               "label"=> "def456"
                            }
                          },
                          {
                            "type"=> "tag",
                            "tag"=> {
                               "type"=> "Course",
                               "label"=> "commoncore"
                            }
                          }
                        ]
                      }
                  },
                  "filter"=> {
                      "restricted"=> {
                          "current_user"=> true,
                          "tags"=> {
                              "all"=> [
                                  {
                                      "type"=> "Alignment",
                                      "name"=> ["def456", "abc123"]
                                  },
                                  {
                                      "type"=> "Course"
                                  }
                              ],
                              "either"=> [
                                  {
                                      "type"=> "Grade",
                                      "name"=> "4"
                                  },
                                  {
                                      "type"=> "Grade",
                                      "name"=> "5"
                                  },
                                  {
                                      "type"=> "Subject",
                                      "name"=> ["Math", "Science"]
                                  }
                              ],
                              "none"=> [
                                  {
                                      "type"=> "Grade",
                                      "name"=> "6"
                                  }
                              ]
                          }
                      }
                  }
              },
              "dependencies"=> {
                  "question_editor_api"=> {
                      "init_options"=> {}
                  },
                  "questions_api"=> {
                      "init_options"=> {}
                  }
              },
              "widget_templates"=> {
                  "back"=> true,
                  "save"=> true,
                  "widget_types"=> {
                      "default"=> "questions",
                      "show"=> true
                  }
              },
              "container"=> {
                  "height"=> "auto",
                  "fixed_footer_height"=> 0,
                  "scroll_into_view_selector"=> "body"
              },
              "label_bundle"=> {
                  "backButton"=> "Zurück",
                  "loadingText"=> "Wird geladen",
                  "modalClose"=> "Schließen",
                  "saveButton"=> "Speichern",
                  "duplicateButton"=> "Duplikat",
                  "dateTimeLocale"=> "en-us",
                  "toolTipDateTimeSeparator"=> "um",
                  "toolTipDateFormat"=> "DD-MM-YYYY",
                  "toolTipTimeFormat"=> "HH:MM:SS",
              }
          },
  }

  def index
    @init = Learnosity::Sdk::Request::Init.new(
      'author',
      @@security_packet,
      @@consumer_secret,
      @@author_request
    )
  end
end
