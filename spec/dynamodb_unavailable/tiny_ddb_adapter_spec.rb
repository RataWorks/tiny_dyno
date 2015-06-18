require 'spec_helper'

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
