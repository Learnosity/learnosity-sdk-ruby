ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Fix for Ruby 2.6 compatibility with Rails 6.1
# Rails 6.1 expects Logger to be available before ActiveSupport loads
require 'logger'
