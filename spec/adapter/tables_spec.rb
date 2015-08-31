require 'spec_helper'

describe TinyDyno::Adapter do

  before(:each) {
    TinyDyno::Adapter.disconnect!
    TinyDyno::Adapter.delete_table(table_name: valid_table_request[:table_name])
  }
  let(:valid_table_request) {{
      attribute_definitions: [
          {
              attribute_name: 'id',
              attribute_type: 'N',
          }
      ],
      table_name: 'valid_table',
      key_schema: [
          {
              attribute_name: 'id',
              key_type: 'HASH'
          }
      ]
  }}.freeze

  context 'tables' do

    before(:all) { TinyDyno::Adapter.disconnect! }

    it 'should add the table_name to the cache' do
      expect(TinyDyno::Adapter.create_table(valid_table_request)).to eq true
      expect(TinyDyno::Adapter.table_names.include?(valid_table_request[:table_name])).to eq true
    end

    it 'should create and delete a table, removing it from the cache' do
      expect(TinyDyno::Adapter.create_table(valid_table_request)).to eq true
      expect(TinyDyno::Adapter.table_exists?(table_name: valid_table_request[:table_name])).to eq true
      expect(TinyDyno::Adapter.delete_table(table_name: valid_table_request[:table_name])).to eq true
      expect(TinyDyno::Adapter.table_exists?(table_name: valid_table_request[:table_name])).to eq false
    end

    it 'should raise an error, when asking to create an existing table' do
      expect(TinyDyno::Adapter.create_table(valid_table_request)).to eq true
      expect{ TinyDyno::Adapter.create_table(valid_table_request) }.to raise_error(Aws::DynamoDB::Errors::ResourceInUseException)
    end

  end
end