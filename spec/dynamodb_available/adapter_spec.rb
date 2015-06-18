require 'spec_helper'

describe "TinyDyno::Adapter is available" do

  before(:each) { TinyDyno::Adapter.disconnect! }

  # TODO, it works, but we don't have a non consequential trigger method available to test this
  #
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

describe "TinyDyno::Adapter, dynamodb endpoint invalid" do

  before(:each) {
    @aws_endpoint = Aws.config[:endpoint]
    Aws.config[:endpoint] = 'http://127.0.0.1:65534'
    TinyDyno::Adapter.disconnect!
  }

  after(:each) { Aws.config[:endpoint] = @aws_endpoint }
  #
  it 'should return false, if there is no connection to dynamodb' do
    expect(TinyDyno::Adapter.connected?).to be false
  end

  describe '#connect' do
    it 'should return false, when attempting to connect' do
      expect(TinyDyno::Adapter.connect).to be false
    end
  end

  describe '#connect' do
    it 'should return false, when attempting to connect' do
      TinyDyno::Adapter.connect
      expect(TinyDyno::Adapter.connected?).to be false
    end
  end

end
