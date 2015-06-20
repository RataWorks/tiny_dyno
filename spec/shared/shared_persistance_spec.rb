require 'set'

shared_examples_for "it is persistable" do
  let(:empty_doc) { described_class.new }
  let(:populated_doc) { Fabricate.build(described_class.to_s.downcase.to_sym) }

  before(:all) {
    TinyDyno::Adapter.disconnect!
    described_class.delete_table
    described_class.create_table
  }

  after(:all) {
    described_class.delete_table
  }

  context 'table is available' do
    it 'should list the table in the table_cache' do
      expect(TinyDyno::Adapter.table_names.include?(described_class.table_name ) ).to be true
    end
  end

  context '#instance_methods' do

    describe '.put_item' do

      it 'persists a new document to dynamodb' do
        expect(populated_doc.save).to eq true
      end

    end
  end

end