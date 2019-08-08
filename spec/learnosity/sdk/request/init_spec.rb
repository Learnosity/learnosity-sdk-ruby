require 'spec_helper'

RSpec.describe Learnosity::Sdk::Request::Init do
  before(:all) do
    Learnosity::Sdk::Request::Init.disable_telemetry
  end

  after(:all) do
    Learnosity::Sdk::Request::Init.enable_telemetry
  end

  security_packet = {
    # XXX: This is a Learnosity Demos consumer; replace it with your own consumer key
    'consumer_key' => 'yis0TYCu7U9V4o7M',
    'domain' => 'localhost',
    'timestamp' => '20140626-0528',
  }
  # XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked in in revision control
  consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'

  items_request = {
    'user_id' => '$ANONYMIZED_USER_ID',
    'rendering_type' => 'assess',
    'name' => 'Items API demo - assess activity demo',
    'state' => 'initial',
    'activity_id' => 'items_assess_demo',
    'session_id' => 'demo_session_uuid',
    'type' => 'submit_practice',
    'config' => {
      'configuration' => {
        'responsive_regions' => true
      },
      'navigation' => {
        'scrolling_indicator' => true
      },
      'regions' => 'main',
      'time' => {
        'show_pause' => true,
        'max_time' => 300
      },
      'title' => 'ItemsAPI Assess Isolation Demo',
      'subtitle' => 'Testing Subtitle Text'
    },
    'items' => [
      'Demo3'
    ]
  }

  context "validation" do
    it 'throws ValidationException on missing service' do
      expect {
        Learnosity::Sdk::Request::Init.new(nil, security_packet, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /service.*empty/
    end

    it 'throws ValidationException on invalid service' do
      expect {
        Learnosity::Sdk::Request::Init.new('invalid service', security_packet, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /service.*not valid/
    end

    it 'throws ValidationException on missing security_packet' do
      expect {
        Learnosity::Sdk::Request::Init.new('items', nil, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /security packet.*Hash/
    end

    it 'throws ValidationException on non-hash security_packet' do
      expect {
        Learnosity::Sdk::Request::Init.new('items', 'not a hash', consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /security packet.*Hash/
    end

    it 'throws ValidationException on unexpected key in security_packet' do
      local_security_packet = security_packet.clone
      local_security_packet['notASecurityKey'] = 'atAll'
      expect {
        Learnosity::Sdk::Request::Init.new('items', local_security_packet, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /Invalid key.*security packet/
    end

    it 'throws ValidationException on missing user_id when initialising Questions API' do
      expect {
        Learnosity::Sdk::Request::Init.new('questions', security_packet, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /Questions.*user_id/
    end

    it 'throws ValidationException on missing secret' do
      expect {
        Learnosity::Sdk::Request::Init.new('items', security_packet, nil)
      }.to raise_exception Learnosity::Sdk::ValidationException, /secret.*string/
    end

    it 'throws ValidationException on invalid secret' do
      expect {
        Learnosity::Sdk::Request::Init.new('items', security_packet, {:notAString => 42})
      }.to raise_exception Learnosity::Sdk::ValidationException, /secret.*string/
    end

    it 'throws ValidationException on non-hash request' do
      expect {
        Learnosity::Sdk::Request::Init.new('items', security_packet, consumer_secret, 'notAHash')
      }.to raise_exception Learnosity::Sdk::ValidationException, /request packet.*hash/
    end

    it 'throws ValidationException on non-string action' do
      expect {
        Learnosity::Sdk::Request::Init.new('items', security_packet, consumer_secret, items_request, {:notAString => 42})
      }.to raise_exception Learnosity::Sdk::ValidationException, /action.*string/
    end

    it 'should add a timestamp to the security packet if missing' do
      local_security_packet = security_packet.clone
      local_security_packet.delete('timestamp')
      init = Learnosity::Sdk::Request::Init.new('items', local_security_packet, consumer_secret)
      expect(init.security_packet).to have_key('timestamp')
    end

    it 'should not raise exceptions with well-formed arguments' do
      expect {
        Learnosity::Sdk::Request::Init.new('items', security_packet, consumer_secret, items_request, 'get')
      }.to_not raise_exception
    end

  end

  context "Assess API" do
    assess_request = {
      "items" => [
        {
          "content" => '<span class="learnosity-response question-demoscience1234"></span>',
          "response_ids" => [
            "demoscience1234"
          ],
          "workflow" => "",
          "reference" => "question-demoscience1"
        },
        {
          "content" => '<span class="learnosity-response question-demoscience5678"></span>',
          "response_ids" => [
            "demoscience5678"
          ],
          "workflow" => "",
          "reference" => "question-demoscience2"
        }
      ],
      "ui_style" => "horizontal",
      "name" => "Demo (2 questions)",
      "state" => "initial",
      "metadata" => [],
      "navigation" => {
        "show_next" => true,
        "toc" => true,
        "show_submit" => true,
        "show_save" => false,
        "show_prev" => true,
        "show_title" => true,
        "show_intro" => true,
      },
      "time" => {
        "max_time" => 600,
        "limit_type" => "soft",
        "show_pause" => true,
        "warning_time" => 60,
        "show_time" => true
      },
      "configuration" => {
        "onsubmit_redirect_url" => "/assessment/",
        "onsave_redirect_url" => "/assessment/",
        "idle_timeout" => true,
        "questionsApiVersion" => "v2"
      },
      "questionsApiActivity" => {
        "user_id" => "$ANONYMIZED_USER_ID",
        "type" => "submit_practice",
        "state" => "initial",
        "id" => "assessdemo",
        "name" => "Assess API - Demo",
        "questions" => [
          {
            "response_id" => "demoscience1234",
            "type" => "sortlist",
            "description" => "In this question, the student needs to sort the events, chronologically earliest to latest.",
            "list" => ["Russian Revolution", "Discovery of the Americas", "Storming of the Bastille", "Battle of Plataea", "Founding of Rome", "First Crusade"],
            "instant_feedback" => true,
            "feedback_attempts" => 2,
            "validation" => {
              "valid_response" => [4, 3, 5, 1, 2, 0],
              "valid_score" => 1,
              "partial_scoring" => true,
              "penalty_score" => -1
            }
          },
          {
            "response_id" => "demoscience5678",
            "type" => "highlight",
            "description" => "The student needs to mark one of the flowers anthers in the image.",
            "img_src" => "http://www.learnosity.com/static/img/flower.jpg",
            "line_color" => "rgb(255, 20, 0)",
            "line_width" => "4"
          }
        ]
      },
      "type" => "activity"
    }

    assess_questions_security_packet = security_packet.clone
    assess_questions_security_packet['user_id'] = '$ANONYMIZED_USER_ID'

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'assess',
        assess_questions_security_packet,
        consumer_secret,
        assess_request
      )
      expect(init.generate_signature).to eq('03f4869659eeaca81077785135d5157874f4800e57752bf507891bf39c4d4a90')
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'assess',
        assess_questions_security_packet,
        consumer_secret,
        assess_request
      )
      expect(init.generate(false)).to eq({"items" => [{"content" => "<span class=\"learnosity-response question-demoscience1234\"></span>", "response_ids" => ["demoscience1234"], "workflow" => "", "reference" => "question-demoscience1"}, {"content" => "<span class=\"learnosity-response question-demoscience5678\"></span>", "response_ids" => ["demoscience5678"], "workflow" => "", "reference" => "question-demoscience2"}], "ui_style" => "horizontal", "name" => "Demo (2 questions)", "state" => "initial", "metadata" => [], "navigation" => {"show_next" => true, "toc" => true, "show_submit" => true, "show_save" => false, "show_prev" => true, "show_title" => true, "show_intro" => true}, "time" => {"max_time" => 600, "limit_type" => "soft", "show_pause" => true, "warning_time" => 60, "show_time" => true}, "configuration" => {"onsubmit_redirect_url" => "/assessment/", "onsave_redirect_url" => "/assessment/", "idle_timeout" => true, "questionsApiVersion" => "v2"}, "questionsApiActivity" => {"user_id" => '$ANONYMIZED_USER_ID', "type" => "submit_practice", "state" => "initial", "id" => "assessdemo", "name" => "Assess API - Demo", "questions" => [{"response_id" => "demoscience1234", "type" => "sortlist", "description" => "In this question, the student needs to sort the events, chronologically earliest to latest.", "list" => ["Russian Revolution", "Discovery of the Americas", "Storming of the Bastille", "Battle of Plataea", "Founding of Rome", "First Crusade"], "instant_feedback" => true, "feedback_attempts" => 2, "validation" => {"valid_response" => [4, 3, 5, 1, 2, 0], "valid_score" => 1, "partial_scoring" => true, "penalty_score" => -1}}, {"response_id" => "demoscience5678", "type" => "highlight", "description" => "The student needs to mark one of the flowers anthers in the image.", "img_src" => "http://www.learnosity.com/static/img/flower.jpg", "line_color" => "rgb(255, 20, 0)", "line_width" => "4"}], "consumer_key" => "yis0TYCu7U9V4o7M", "timestamp" => "20140626-0528", "signature" => "03f4869659eeaca81077785135d5157874f4800e57752bf507891bf39c4d4a90"}, "type" => "activity"})
    end
  end

  context "Author API" do
    author_request = {
      "mode" => "item_list",
      "config" => {
        "item_list" => {
          "item" => {
            "status" => true
          }
        }
      },
      "user" => {
        "id" => "walterwhite",
        "firstname" => "walter",
        "lastname" => "white"
      }
    }

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'author',
        security_packet,
        consumer_secret,
        author_request
      )
      expect(init.generate_signature).to eq('108b985a4db36ef03905572943a514fc02ed7cc6b700926183df7babc2cd1c96')
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'author',
        security_packet,
        consumer_secret,
        author_request
      )
      expect(init.generate(true)).to eq('{"security":{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"108b985a4db36ef03905572943a514fc02ed7cc6b700926183df7babc2cd1c96"},"request":{"mode":"item_list","config":{"item_list":{"item":{"status":true}}},"user":{"id":"walterwhite","firstname":"walter","lastname":"white"}}}')
    end
  end

  context "Data API" do
    data_request = {'limit' => 100}

    it 'can generate signature for GET' do
      init = Learnosity::Sdk::Request::Init.new(
        'data',
        security_packet,
        consumer_secret,
        data_request,
        'get'
      )
      expect(init.generate_signature).to eq("e1eae0b86148df69173cb3b824275ea73c9c93967f7d17d6957fcdd299c8a4fe")
    end

    it 'can generate signature for POST' do
      init = Learnosity::Sdk::Request::Init.new(
        'data',
        security_packet,
        consumer_secret,
        data_request,
        'post'
      )
      expect(init.generate_signature).to eq("18e5416041a13f95681f747222ca7bdaaebde057f4f222083881cd0ad6282c38")
    end

    it 'can generate signature for GET with expiry' do
      data_expires_security_packet = security_packet.clone
      data_expires_security_packet['expires'] = '20160621-1716'

      init = Learnosity::Sdk::Request::Init.new(
        'data',
        data_expires_security_packet,
        consumer_secret,
        data_request,
        'get'
      )
      expect(init.generate_signature).to eq("5d962d5fea8e5413bddc0f304650c4b58ed4419015e47934452127dc2120fd8a")
    end

    it 'can generate init options for GET' do
      init = Learnosity::Sdk::Request::Init.new(
        'data',
        security_packet,
        consumer_secret,
        data_request,
        'get'
      )
      expect(init.generate).to eq(
                                   {
                                     'security' => '{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"e1eae0b86148df69173cb3b824275ea73c9c93967f7d17d6957fcdd299c8a4fe"}',
                                     'request' => '{"limit":100}',
                                     'action' => 'get'
                                   }
                                 )
    end

    it 'can generate init options for POST' do
      init = Learnosity::Sdk::Request::Init.new(
        'data',
        security_packet,
        consumer_secret,
        data_request,
        'post'
      )
      expect(init.generate).to eq(
                                   {
                                     'security' => '{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"18e5416041a13f95681f747222ca7bdaaebde057f4f222083881cd0ad6282c38"}',
                                     'request' => '{"limit":100}',
                                     'action' => 'post'
                                   }
                                 )
    end
  end

  context "Events API" do
    events_request = {
      'users' => {
        '$ANONYMIZED_USER_ID_1' => '',
        '$ANONYMIZED_USER_ID_2' => '',
        '$ANONYMIZED_USER_ID_3' => '',
        '$ANONYMIZED_USER_ID_4' => '',
      }
    }

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'events',
        security_packet,
        consumer_secret,
        events_request
      )
      expect(init.generate_signature).to eq('20739eed410d54a135e8cb3745628834886ab315bfc01693ce9acc0d14dc98bf')
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'events',
        security_packet,
        consumer_secret,
        events_request
      )
      expect(init.generate(true)).to eq(
                                       '{"security":{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"20739eed410d54a135e8cb3745628834886ab315bfc01693ce9acc0d14dc98bf"},"config":{"users":{"$ANONYMIZED_USER_ID_1":"64ccf06154cf4133624372459ebcccb8b2f8bd7458a73df681acef4e742e175c","$ANONYMIZED_USER_ID_2":"7fa4d6ef8926add8b6411123fce916367250a6a99f50ab8ec39c99d768377adb","$ANONYMIZED_USER_ID_3":"3d5b26843da9192319036b67f8c5cc26e1e1763811270ba164665d0027296952","$ANONYMIZED_USER_ID_4":"3b6ac78f60f3e3eb7a85cec8b48bdca0f590f959e0a87a9c4222898678bd50c8"}}}',
                                     )
    end
  end

  context "Items API" do
    it 'copies user_id from request to security packet if present' do
      init = Learnosity::Sdk::Request::Init.new(
        'items',
        security_packet,
        consumer_secret,
        items_request
      )
      expect(init.security_packet).to have_key('user_id')
    end

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'items',
        security_packet,
        consumer_secret,
        items_request
      )

      expect(init.generate_signature).to eq("82edaf80c2abb55c7a78d089f5b6f89393e621ef4a85150489ac2cfdd6a32f9a")
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'items',
        security_packet,
        consumer_secret,
        items_request
      )

      expect(init.generate).to eq('{"security":{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","user_id":"$ANONYMIZED_USER_ID","signature":"82edaf80c2abb55c7a78d089f5b6f89393e621ef4a85150489ac2cfdd6a32f9a"},"request":{"user_id":"$ANONYMIZED_USER_ID","rendering_type":"assess","name":"Items API demo - assess activity demo","state":"initial","activity_id":"items_assess_demo","session_id":"demo_session_uuid","type":"submit_practice","config":{"configuration":{"responsive_regions":true},"navigation":{"scrolling_indicator":true},"regions":"main","time":{"show_pause":true,"max_time":300},"title":"ItemsAPI Assess Isolation Demo","subtitle":"Testing Subtitle Text"},"items":["Demo3"]}}')
    end
  end

  context "Questions API" do
    questions_request = {
      'type' => 'local_practice',
      'state' => 'initial',
      'questions' => [
        {
          'response_id' => '60005',
          'type' => 'association',
          'stimulus' => 'Match the cities to the parent nation.',
          'stimulus_list' => ['London', 'Dublin', 'Paris', 'Sydney'],
          'possible_responses' => ['Australia', 'France', 'Ireland', 'England'],
          'validation' => {
            'valid_responses' => [
              ['England'], ['Ireland'], ['France'], ['Australia']
            ]
          }
        }
      ]
    }

    questions_security_packet = security_packet.clone
    questions_security_packet['user_id'] = '$ANONYMIZED_USER_ID'

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request
      )
      expect(init.generate_signature).to eq("03f4869659eeaca81077785135d5157874f4800e57752bf507891bf39c4d4a90")
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request
      )
      expect(init.generate(false)).to eq({"consumer_key" => "yis0TYCu7U9V4o7M", "timestamp" => "20140626-0528", "user_id" => "$ANONYMIZED_USER_ID", "signature" => "03f4869659eeaca81077785135d5157874f4800e57752bf507891bf39c4d4a90", "type" => "local_practice", "state" => "initial", "questions" => [{"response_id" => "60005", "type" => "association", "stimulus" => "Match the cities to the parent nation.", "stimulus_list" => ["London", "Dublin", "Paris", "Sydney"], "possible_responses" => ["Australia", "France", "Ireland", "England"], "validation" => {"valid_responses" => [["England"], ["Ireland"], ["France"], ["Australia"]]}}]})
    end
  end

  context "Reports API" do
    reports_request = {
      "reports" => [
        {
          "id" => "report-1",
          "type" => "sessions-summary",
          "user_id" => "$ANONYMIZED_USER_ID",
          "session_ids" => [
            "AC023456-2C73-44DC-82DA28894FCBC3BF"
          ]
        }
      ]
    }

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'reports',
        security_packet,
        consumer_secret,
        reports_request
      )
      expect(init.generate_signature).to eq('91085beccf57bf0df77c89df94d1055e631b36bc11941e61460b445b4ed774bc')
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'reports',
        security_packet,
        consumer_secret,
        reports_request
      )
      expect(init.generate(true)).to eq('{"security":{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"91085beccf57bf0df77c89df94d1055e631b36bc11941e61460b445b4ed774bc"},"request":{"reports":[{"id":"report-1","type":"sessions-summary","user_id":"$ANONYMIZED_USER_ID","session_ids":["AC023456-2C73-44DC-82DA28894FCBC3BF"]}]}}')
    end
  end

  context "SDK Telemetry" do
    questions_request = {
      'type' => 'local_practice',
      'state' => 'initial',
      'questions' => [
        {
          'response_id' => '60005',
          'type' => 'association',
          'stimulus' => 'Match the cities to the parent nation.',
          'stimulus_list' => ['London', 'Dublin', 'Paris', 'Sydney'],
          'possible_responses' => ['Australia', 'France', 'Ireland', 'England'],
          'validation' => {
            'valid_responses' => [
              ['England'], ['Ireland'], ['France'], ['Australia']
            ]
          }
        }
      ]
    }
    questions_security_packet = security_packet.clone
    questions_security_packet['user_id'] = '$ANONYMIZED_USER_ID'

    it 'has meta key and sdk key when telemetry enabled' do
      Learnosity::Sdk::Request::Init.enable_telemetry

      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request
      )
      req = init.generate(false)
      expect(req[:meta]).not_to be_nil
      expect(req[:meta][:sdk]).not_to be_nil

      Learnosity::Sdk::Request::Init.disable_telemetry
    end

    it 'does not have meta tag when telemetry disabled' do
      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request
      )
      req = init.generate(false)
      expect(req[:meta]).to be_nil
    end

    it 'does not affect existing meta key when telemetry is enabled' do
      Learnosity::Sdk::Request::Init.enable_telemetry

      questions_request_key = questions_request.clone

      questions_request_key['meta'] = {
        :test => 123,
        :test2 => 456
      }

      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request_key
      )
      req = init.generate(false)
      expect(req['meta']).not_to be_nil
      expect(req['meta'][:test]).not_to be_nil
      expect(req['meta'][:test2]).not_to be_nil
      expect(req['meta'][:sdk]).not_to be_nil

      Learnosity::Sdk::Request::Init.disable_telemetry
    end

    it 'does not affect existing meta symbol when telemetry is enabled' do
      Learnosity::Sdk::Request::Init.enable_telemetry

      questions_request_symbol = questions_request.clone

      questions_request_symbol[:meta] = {
        :test => 123,
        :test2 => 456
      }

      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request_symbol
      )
      req = init.generate(false)
      expect(req[:meta]).not_to be_nil
      expect(req[:meta][:test]).not_to be_nil
      expect(req[:meta][:test2]).not_to be_nil
      expect(req[:meta][:sdk]).not_to be_nil

      Learnosity::Sdk::Request::Init.disable_telemetry
    end

    it 'does not affect existing meta key when telemetry is disabled' do
      questions_request['meta'] = {
        :test => 123,
        :test2 => 456
      }

      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request
      )
      req = init.generate(false)
      expect(req['meta']).not_to be_nil
    end

    it 'does not affect existing meta symbol when telemetry is disabled' do
      questions_request[:meta] = {
        :test => 123,
        :test2 => 456
      }

      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request
      )
      req = init.generate(false)
      expect(req[:meta]).not_to be_nil
    end
  end
end

# vim: sw=2
