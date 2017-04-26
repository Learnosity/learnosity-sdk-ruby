require "bundler/setup"
require "learnosity/sdk"
require "learnosity/sdk/exceptions"
require "learnosity/sdk/request"
require "learnosity/sdk/request/init"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
