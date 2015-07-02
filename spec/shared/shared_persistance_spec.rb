require 'set'

shared_examples_for "it is persistable" do
  let(:empty_doc) { described_class.new }
  let(:populated_doc) { Fabricate.build(described_class.to_s.downcase.to_sym) }

  before(:each) {
    TinyDyno::Adapter.disconnect!
    described_class.delete_table
    described_class.create_table
  }

  after(:each) {
    described_class.delete_table
  }

  context 'table is available' do
    it 'should list the table in the table_cache' do
      expect(TinyDyno::Adapter.table_names.include?(described_class.table_name ) ).to be true
    end

    it 'will return true if a create_table request is issued for an existing table' do
      expect(described_class.create_table).to eq true
    end

    it 'will raise an exception, if a create_table request is issued for an existing table' do
      expect{ described_class.create_table! }.to raise_error(Aws::DynamoDB::Errors::ResourceInUseException)
    end

  end

  context '#instance_methods' do
    describe '.put_item' do
      context 'success' do

        it 'persists a new document to dynamodb' do
          expect(populated_doc.save).to eq true
          expect(populated_doc.persisted?).to eq true
        end

        it 'resets the changed flag to false' do
          expect(populated_doc.save).to eq true
          expect(populated_doc.changed?).to eq false
        end

        it 'resets the changed_attributes hash' do
          expect(populated_doc.save).to eq true
          expect(populated_doc.changed_attributes).to eq ({})
        end

      end
    end

    describe '.delete_item' do
      it 'deletes an existing document' do
        new_person = Fabricate.create(:person)
        new_person.save
        last_person = Person.where(id: new_person.id)
        expect(last_person.delete).to eq true
      end
    end

    it 'does not overwrite existing records' do
      new_person = Fabricate.create(:person)
      new_person.save
      another_person = Fabricate.create(:person)
      another_person.id = new_person.id
      expect { another_person.save }.to raise_error(Aws::DynamoDB::Errors::ConditionalCheckFailedException)
    end

  end

end