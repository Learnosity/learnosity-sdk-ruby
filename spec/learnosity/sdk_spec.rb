require "spec_helper"

RSpec.describe Learnosity::Sdk do
  it "has a version number" do
    expect(Learnosity::Sdk::VERSION).not_to be nil
  end
end

# vim: sw=2
