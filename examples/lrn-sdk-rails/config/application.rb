require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LrnSdkRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # The consumerKey and consumerSecret are the public & private
    # security keys required to access Learnosity APIs and
    # data. Learnosity will provide keys for your own private account.
    # Note: The consumer secret should be in a properly secured credential store, 
    # and *NEVER* checked into version control. 
    # The keys listed here grant access to Learnosity's public demos account.
    config.consumer_key = 'yis0TYCu7U9V4o7M'
    config.consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
  end
end
