require 'spec_helper'

describe TinyDyno::Adapter do

  before(:each) { TinyDyno::Adapter.disconnect! }

  context 'lazy connection' do
    it 'should lazily establish a connection' do
      TinyDyno::Adapter.update_table_cache
      expect(TinyDyno::Adapter.connected?).to eql true
    end
  end

  context 'connected' do

    describe 'connect' do
      it 'should connect to DynamoDB' do
        expect(TinyDyno::Adapter.connect).to be true
      end
    end

    describe '.connected?' do

      it 'should return true, if a connection to dynamodb exists' do
        TinyDyno::Adapter.connect
        expect(TinyDyno::Adapter.connected?).to eql true
      end

      it 'should return false, if a connection to dynamodb does not exists' do
        TinyDyno::Adapter.disconnect!
        expect(TinyDyno::Adapter.connected?).to eql false
      end

    end
  end

end
