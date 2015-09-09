require 'spec_helper'
require 'securerandom'

describe Person do
  it_behaves_like "it is persistable"
end

describe 'NonExistingDocs' do
  let(:empty_doc) { Person.new }
  let(:populated_doc) { Fabricate.build(:person) }

  before(:each) {
    Person.delete_table
    Person.create_table
  }

  after(:each) {
    Person.delete_table
  }

  it 'returns nil for a non existing document' do
    expect(Person.where(id: SecureRandom.uuid).nil?).to be true
  end

end