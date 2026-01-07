require 'securerandom'

module Learnosity
  module Sdk
    module Utils
      # UUID utility for generating UUIDv4 identifiers
      # Commonly used for user_id and session_id in Learnosity API requests
      class Uuid
        # Generate a UUIDv4 string
        #
        # @return [String] A UUIDv4 string
        def self.generate
          SecureRandom.uuid
        end
      end
    end
  end
end

# vim: sw=2

