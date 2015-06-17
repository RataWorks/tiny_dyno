require 'spec_helper'

describe TinyDyno::Adapter do

  it 'should return false, if there is no connection to dynamodb' do
    expect(TinyDyno::Adapter.connected?).to be false
  end

end
