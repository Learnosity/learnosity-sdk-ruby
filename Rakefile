require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "./lib/learnosity/sdk/version"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :version do
    puts Learnosity::Sdk::VERSION
end

task :clean do
    ["Gemfile.lock", ".rspec_status"].each {|f| File.delete(f) rescue nil}
end
