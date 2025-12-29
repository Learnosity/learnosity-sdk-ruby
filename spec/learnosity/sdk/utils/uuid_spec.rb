require "spec_helper"
require "learnosity/sdk/utils/uuid"

RSpec.describe Learnosity::Sdk::Utils::Uuid do
  describe ".generate" do
    it "generates a valid UUIDv4 string" do
      uuid = Learnosity::Sdk::Utils::Uuid.generate
      
      # UUIDv4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
      # where y is one of [8, 9, a, b]
      uuid_v4_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
      
      expect(uuid).to be_a(String)
      expect(uuid.length).to eq(36)
      expect(uuid).to match(uuid_v4_regex)
    end
    
    it "generates unique UUIDs" do
      uuid1 = Learnosity::Sdk::Utils::Uuid.generate
      uuid2 = Learnosity::Sdk::Utils::Uuid.generate
      
      expect(uuid1).not_to eq(uuid2)
    end
    
    it "is accessible via Learnosity::Sdk::Uuid" do
      expect(Learnosity::Sdk::Uuid).to eq(Learnosity::Sdk::Utils::Uuid)
      expect(Learnosity::Sdk::Uuid).to respond_to(:generate)
    end
    
    it "generates 1000 unique UUIDs" do
      uuids = Set.new
      
      1000.times do
        uuids.add(Learnosity::Sdk::Utils::Uuid.generate)
      end
      
      expect(uuids.size).to eq(1000)
    end
  end
end

# vim: sw=2

