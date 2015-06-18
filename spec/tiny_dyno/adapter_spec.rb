require 'spec_helper'

describe "TinyDyno::Adapter is available" do

  before(:each) { TinyDyno::Adapter.disconnect! }

  it 'should lazily establish a connection' do
    expect(TinyDyno::Adapter.connected?).to eql true
  end

  describe 'connect' do
    it 'should connect to DynamoDB' do
      expect(TinyDyno::Adapter.connect).to be true
    end
  end

  # This is somewhat dubious, or maybe just labelled wrong
  # state is held locally
  # and connections are only established when needed
  # so we're asking the wrong question here
  # instantiated may be the better term ...
   describe '.connected?' do

    it 'should return true, if a connection to dynamodb exists' do
      TinyDyno::Adapter.connect
      expect(TinyDyno::Adapter.connected?).to eql true
    end

    # this is not possible,
    # as implemented a call will always succeed, if the configured dynamodb service is available
    #
    # it 'should return false, if a connection to dynamodb does not exists' do
    #   TinyDyno::Adapter.disconnect!
    #   expect(TinyDyno::Adapter.connected?).to eql false
    # end

  end

end
