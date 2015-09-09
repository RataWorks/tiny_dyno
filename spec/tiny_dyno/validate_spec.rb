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

  it 'returns false, when attempting to save an invalid document and no options provided' do
    populated_doc.label = nil
    expect(populated_doc.valid?).to be false
    expect(populated_doc.save).to be false
    expect(populated_doc.errors.class).to eq ActiveModel::Errors
  end

  it 'returns true, when attempting to save an invalid document, with validate: false passed' do
    populated_doc.label = nil
    expect(populated_doc.valid?).to be false
    expect(populated_doc.save({validate: false})).to be true
  end

  it 'returns false, when attempting to save an invalid document, with validate: true passed' do
    populated_doc.label = nil
    expect(populated_doc.valid?).to be false
    expect(populated_doc.save({validate: true})).to be false
  end

end