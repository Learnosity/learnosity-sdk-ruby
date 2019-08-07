#!/usr/bin/env ruby
require 'net/http'
require 'json'

require 'learnosity/sdk/request/init'

activityId = 'demoActivity'
maxCount = 100

class SessionDiscarder
	def initialize
		@sessionsStatusesUri = URI('https://data.learnosity.com/v1/sessions/statuses')

		@security_packet = {
			# XXX: This is a Learnosity Demos consumer; replace it with your own consumer key
			'consumer_key'   => 'yis0TYCu7U9V4o7M',
			'domain'         => 'localhost'
		}
		# XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked in in revision control
		@consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
	end

	def get_sessions_statuses(sessionIds)
		request = { "session_id": sessionIds }
		return do_get_sessions_statuses(request)
	end

	def get_sessions_statuses_by_activity(activityId)
		request = { "activity_id": [ activityId ] }
		return do_get_sessions_statuses(request)
	end

	def do_get_sessions_statuses(request)

		reqno = 0
		continue = true
		sessions = []
		while continue do
			reqno += 1

			init = Learnosity::Sdk::Request::Init.new(
				'data',
				@security_packet,
				@consumer_secret,
				request
			)
			signedRequest = init.generate

			puts ">>> [#{@sessionsStatusesUri} (#{reqno})] #{JSON::generate(signedRequest)}"

			res = Net::HTTP.post_form(@sessionsStatusesUri, signedRequest)
			response = JSON.parse(res.body)

			puts "<<< [#{res.code}] #{response['meta']['records']} records, next: #{response['meta']['next']}"

			if ( !response['meta']['next'].nil? \
					and !response['meta']['records'].nil? and response['meta']['records'] > 0)
				request['next'] = response['meta']['next']
			else
				continue = false
			end

			response['data'].each { |session|
				sessions += [ session ]
			}
		end
		return sessions
	end

	def update_statuses(statuses)
		sessionsDiscardRequest = { "statuses": statuses }

		init = Learnosity::Sdk::Request::Init.new(
			'data',
			@security_packet,
			@consumer_secret,
			sessionsDiscardRequest,
			'update'
		)
		request = init.generate

		puts ">>> [#{@sessionsStatusesUri}] #{JSON::generate(sessionsDiscardRequest)}"

		res = Net::HTTP.post_form(@sessionsStatusesUri, request)
		response = JSON.parse(res.body)

		puts "<<< [#{res.code}] job_reference: #{response['data']['job_reference']}"
	end
end

sd = SessionDiscarder.new

sessions = sd.get_sessions_for_activity(activityId)

statuses = []
sessions.each { |session|
	if session['status'] != 'Discarded'
		session['status'] = 'Discarded'
		statuses += [ session ]
		if statuses.count == maxCount
			sd.update_statuses(statuses)
			statuses = []
		end
	end
}
if statuses.count > 0
	sd.update_statuses(statuses)
end
