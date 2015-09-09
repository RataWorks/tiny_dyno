require 'spec_helper'

describe 'ValidatingDocs' do
  let(:empty_doc) { Account.new }
  let(:populated_doc) { Fabricate.build(:account) }

  before(:each) {
    Account.delete_table
    Account.create_table
  }

  after(:each) {
    Account.delete_table
  }

  it 'returns false, when attempting to save an invalid document' do
    expect(empty_doc.valid?).to be false
    expect(empty_doc.save).to be false
    expect(empty_doc.errors.class).to eq ActiveModel::Errors
  end

end