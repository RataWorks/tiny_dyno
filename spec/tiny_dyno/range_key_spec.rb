require 'spec_helper'

describe TinyDyno::Fields::RangeKey do

  it 'does register fields marked as range_type in the attribute_definitions' do
    expect(Account.attribute_definitions).to eq([{:attribute_name=>"id", :attribute_type=>"S"}, {:attribute_name=>"email", :attribute_type=>"S"}])
  end

  it 'does register fields marked as range_type in the key_schema' do
    expect(Account.key_schema).to eq([{:attribute_name=>"id", :key_type=>"HASH"}, {:attribute_name=>"email", :key_type=>"RANGE"}])
  end

  context 'LOOKUPS' do
    before(:each) {
      TinyDyno::Adapter.disconnect!
      Account.delete_table
      Account.create_table
    }

    after(:each) {
      Account.delete_table
    }

    it 'enables look ups by range key' do
      account = Fabricate(:account)
      account.save
      same_account = Account.where(id: account.id, email: account.email)
      expect(account.attributes).to eq(same_account.attributes)
    end

    it 'raises an error, when specifying a non key field as selector' do
      expect { Account.where(id: '1', label: 'foo') }.to raise_error (TinyDyno::Errors::InvalidSelector)
    end

    it 'adds the range key to a delete request, when the document has a range defined' do
      account = Fabricate(:account)
      expect(account.save).to be true
      expect(account.delete).to be true
    end

  end

end