require "spec_helper"

RSpec.describe 'utils' do
    context 'hash_except' do
        it 'removes the requested key from the hash' do
            h = { :a => :a, :b => :b }
            expect(hash_except(h, :b)).to eq({:a => :a})
        end
    end
end
