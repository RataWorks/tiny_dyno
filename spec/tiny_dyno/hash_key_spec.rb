require 'spec_helper'

describe TinyDyno::HashKey do

  it 'only permits one hash_key to be defined' do
    expect {
    class OneHashKey
      include TinyDyno::Document

      hash_key :foo, type: Integer
      hash_key :bar, type: Integer

    end
    }.to raise_error(TinyDyno::Errors::OnlyOneHashKeyPermitted)
  end

  it 'requires one hash key to be defined'

end