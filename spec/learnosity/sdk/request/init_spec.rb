require "spec_helper"

RSpec.describe Learnosity::Sdk::Request::Init do
  security_packet = {
    'consumer_key'   => 'yis0TYCu7U9V4o7M',
    'domain'         => 'localhost',
    'timestamp'      => '20140626-0528',
  }
  consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'

  items_request = { 'limit' => 50 }

  context "validation" do
    it 'throws ValidationException on missing service' do
      expect{
        Learnosity::Sdk::Request::Init.new(nil, security_packet, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /service.*empty/
    end

    it 'throws ValidationException on invalid service' do
      expect{
        Learnosity::Sdk::Request::Init.new('invalid service', security_packet, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /service.*not valid/
    end

    it 'throws ValidationException on missing security_packet' do
      expect{
        Learnosity::Sdk::Request::Init.new('items', nil, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /security packet.*Hash/
    end

    it 'throws ValidationException on non-hash security_packet' do
      expect{
        Learnosity::Sdk::Request::Init.new('items', 'not a hash', consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /security packet.*Hash/
    end

    it 'throws ValidationException on unexpected key in security_packet' do
      local_security_packet = security_packet.clone
      local_security_packet['notASecurityKey'] = 'atAll'
      expect{
        Learnosity::Sdk::Request::Init.new('items', local_security_packet, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException , /Invalid key.*security packet/
    end

    it 'throws ValidationException on missing user_id when initialising Questions API' do
      expect{
        Learnosity::Sdk::Request::Init.new('questions', security_packet, consumer_secret)
      }.to raise_exception Learnosity::Sdk::ValidationException, /Questions.*user_id/
    end

    it 'throws ValidationException on missing secret' do
      expect{
        Learnosity::Sdk::Request::Init.new('items', security_packet, nil)
      }.to raise_exception Learnosity::Sdk::ValidationException, /secret.*string/
    end

    it 'throws ValidationException on invalid secret' do
      expect{
        Learnosity::Sdk::Request::Init.new('items', security_packet, { :notAString => 42})
      }.to raise_exception Learnosity::Sdk::ValidationException, /secret.*string/
    end

    it 'throws ValidationException on non-hash request' do
      expect{
        Learnosity::Sdk::Request::Init.new('items', security_packet, consumer_secret, 'notAHash')
      }.to raise_exception Learnosity::Sdk::ValidationException, /request packet.*hash/
    end

    it 'throws ValidationException on non-string action' do
      expect{
        Learnosity::Sdk::Request::Init.new('items', security_packet, consumer_secret, items_request, { :notAString => 42})
      }.to raise_exception Learnosity::Sdk::ValidationException, /action.*string/
    end

    it 'should add a timestamp to the security packet if missing' do
      local_security_packet = security_packet.clone
      local_security_packet.delete('timestamp')
      init = Learnosity::Sdk::Request::Init.new('items', local_security_packet, consumer_secret)
      expect(init.security_packet).to have_key('timestamp')
    end

    it 'should not raise exceptions with well-formed arguments' do
      expect{
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
      "ui_style" =>"horizontal",
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
	"user_id" => "demo_student",
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
    assess_questions_security_packet['user_id'] = 'demo_student'

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'assess',
        assess_questions_security_packet,
        consumer_secret,
        assess_request
      )
      expect(init.generate_signature()).to eq('0969eed4ca4bf483096393d13ee1bae35b993e5204ab0f90cc80eaa055605295')
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'assess',
        assess_questions_security_packet,
        consumer_secret,
        assess_request
      )
      expect(init.generate(false)).to eq({"items" => [{"content" => "<span class=\"learnosity-response question-demoscience1234\"></span>","response_ids" => ["demoscience1234"],"workflow" => "","reference" => "question-demoscience1"},{"content" => "<span class=\"learnosity-response question-demoscience5678\"></span>","response_ids" => ["demoscience5678"],"workflow" => "","reference" => "question-demoscience2"}],"ui_style" => "horizontal","name" => "Demo (2 questions)","state" => "initial","metadata" => [],"navigation" => {"show_next" => true,"toc" => true,"show_submit" => true,"show_save" => false,"show_prev" => true,"show_title" => true,"show_intro" => true},"time" => {"max_time" => 600,"limit_type" => "soft","show_pause" => true,"warning_time" => 60,"show_time" => true},"configuration" => {"onsubmit_redirect_url" => "/assessment/","onsave_redirect_url" => "/assessment/","idle_timeout" => true,"questionsApiVersion" => "v2"},"questionsApiActivity" => {"user_id" => 'demo_student',"type" => "submit_practice","state" => "initial","id" => "assessdemo","name" => "Assess API - Demo","questions" => [{"response_id" => "demoscience1234","type" => "sortlist","description" => "In this question, the student needs to sort the events, chronologically earliest to latest.","list" => ["Russian Revolution","Discovery of the Americas","Storming of the Bastille","Battle of Plataea","Founding of Rome","First Crusade"],"instant_feedback" => true,"feedback_attempts" => 2,"validation" => {"valid_response" => [4,3,5,1,2,0],"valid_score" => 1,"partial_scoring" => true,"penalty_score" => -1}},{"response_id" => "demoscience5678","type" => "highlight","description" => "The student needs to mark one of the flowers anthers in the image.","img_src" => "http://www.learnosity.com/static/img/flower.jpg","line_color" => "rgb(255, 20, 0)","line_width" => "4"}],"consumer_key" => "yis0TYCu7U9V4o7M","timestamp" => "20140626-0528","signature" => "0969eed4ca4bf483096393d13ee1bae35b993e5204ab0f90cc80eaa055605295"},"type" => "activity"})
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
      expect(init.generate_signature()).to eq('108b985a4db36ef03905572943a514fc02ed7cc6b700926183df7babc2cd1c96')
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
    data_request = { 'limit' => 100 }

    it 'can generate signature for GET' do
      init = Learnosity::Sdk::Request::Init.new(
        'data',
        security_packet,
        consumer_secret,
        data_request,
	'get'
      )
      expect(init.generate_signature()).to eq("e1eae0b86148df69173cb3b824275ea73c9c93967f7d17d6957fcdd299c8a4fe")
    end

    it 'can generate signature for POST' do
      init = Learnosity::Sdk::Request::Init.new(
        'data',
        security_packet,
        consumer_secret,
        data_request,
	'post'
      )
      expect(init.generate_signature()).to eq("18e5416041a13f95681f747222ca7bdaaebde057f4f222083881cd0ad6282c38")
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
      expect(init.generate_signature()).to eq("5d962d5fea8e5413bddc0f304650c4b58ed4419015e47934452127dc2120fd8a")
    end

    it 'can generate init options for GET' do
      init = Learnosity::Sdk::Request::Init.new(
        'data',
        security_packet,
        consumer_secret,
        data_request,
	'get'
      )
      expect(init.generate()).to eq(
                {
                    'security' => '{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"e1eae0b86148df69173cb3b824275ea73c9c93967f7d17d6957fcdd299c8a4fe"}',
                    'request'  => '{"limit":100}',
                    'action'   => 'get'
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
      expect(init.generate()).to eq(
		{
                    'security' => '{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"18e5416041a13f95681f747222ca7bdaaebde057f4f222083881cd0ad6282c38"}',
                    'request'  => '{"limit":100}',
                    'action'   => 'post'
		}
      )
    end
  end

  context "Events API" do
    events_request = {
      'users' => {
	'brianmoser' => '',
	'hankshrader' => '',
	'jessepinkman' => '',
	'walterwhite' => '',
      }
    }

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'events',
        security_packet,
        consumer_secret,
        events_request
      )
      expect(init.generate_signature()).to eq('20739eed410d54a135e8cb3745628834886ab315bfc01693ce9acc0d14dc98bf')
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'events',
        security_packet,
        consumer_secret,
        events_request
      )
      expect(init.generate(true)).to eq(
            '{"security":{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"20739eed410d54a135e8cb3745628834886ab315bfc01693ce9acc0d14dc98bf"},"config":{"users":{"brianmoser":"7224f1cd26c7eaac4f30c16ccf8e143005734089724affe0dd9cbf008b941e2d","hankshrader":"3f3edf8ad1f7d64186089308c34d0aee9d09324d1006df6dd3ce57ddc42c7f47","jessepinkman":"ca2d79d6e1c6c926f2b49f3d6052c060bed6b45e42786ff6c5293b9f3c723bdf","walterwhite":"fd1888ffc8cf87efb4ab620401130c76fc8dff5ca04f139e23a7437c56f8f310"}}}',
)
    end
  end

  context "Items API" do
    it 'copies user_id from request to security packet if present' do
      local_items_request = items_request.clone
      local_items_request['user_id'] = 'demo_student'
      init = Learnosity::Sdk::Request::Init.new(
        'items',
        security_packet,
        consumer_secret,
        local_items_request
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
      expect(init.generate_signature()).to eq("d61a62083712f8136e92b40a2c5ea340c77c81a30482da6c19b9c27e72d1f5eb")
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'items',
        security_packet,
        consumer_secret,
        items_request
      )
      expect(init.generate()).to eq('{"security":{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"d61a62083712f8136e92b40a2c5ea340c77c81a30482da6c19b9c27e72d1f5eb"},"request":{"limit":50}}')
    end
  end

  context "Questions API" do

    questions_request = {
      'type' =>			'local_practice',
      'state' =>			'initial',
      'questions' =>			[
        {
          'response_id' =>		'60005',
          'type' =>				'association',
          'stimulus' =>			'Match the cities to the parent nation.',
          'stimulus_list' =>		['London', 'Dublin', 'Paris', 'Sydney'],
          'possible_responses' =>	['Australia', 'France', 'Ireland', 'England'],
          'validation' =>			{
            'valid_responses' =>	[
              ['England'], ['Ireland'], ['France'], ['Australia']
            ]
          }
        }
      ]
    }
    questions_security_packet = security_packet.clone
    questions_security_packet['user_id'] = 'demo_student'

    it 'can generate signature' do
      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request
      )
      expect(init.generate_signature()).to eq("0969eed4ca4bf483096393d13ee1bae35b993e5204ab0f90cc80eaa055605295")
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'questions',
        questions_security_packet,
        consumer_secret,
        questions_request
      )
      expect(init.generate(false)).to eq({"consumer_key"=>"yis0TYCu7U9V4o7M","timestamp"=>"20140626-0528","user_id"=>"demo_student","signature"=>"0969eed4ca4bf483096393d13ee1bae35b993e5204ab0f90cc80eaa055605295","type"=>"local_practice","state"=>"initial","questions"=>[{"response_id"=>"60005","type"=>"association","stimulus"=>"Match the cities to the parent nation.","stimulus_list"=>["London","Dublin","Paris","Sydney"],"possible_responses"=>["Australia","France","Ireland","England"],"validation"=>{"valid_responses"=>[["England"],["Ireland"],["France"],["Australia"]]}}]})
    end
  end

  context "Reports API" do
    reports_request = {
           "reports" => [
               {
                   "id" => "report-1",
                   "type" => "sessions-summary",
                   "user_id" => "brianmoser",
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
      expect(init.generate_signature()).to eq('217d82b0eb98b53e49f9367bed5a8c29d61e661946341c83cb2fcdbead78a8b2')
    end

    it 'can generate init options' do
      init = Learnosity::Sdk::Request::Init.new(
        'reports',
        security_packet,
        consumer_secret,
        reports_request
      )
      expect(init.generate(true)).to eq('{"security":{"consumer_key":"yis0TYCu7U9V4o7M","domain":"localhost","timestamp":"20140626-0528","signature":"217d82b0eb98b53e49f9367bed5a8c29d61e661946341c83cb2fcdbead78a8b2"},"request":{"reports":[{"id":"report-1","type":"sessions-summary","user_id":"brianmoser","session_ids":["AC023456-2C73-44DC-82DA28894FCBC3BF"]}]}}')
    end
  end
end

# vim: sw=2
