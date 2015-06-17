require 'spec_helper'

describe TinyDyno::Adapter do

  # TODO, capture this when refactoring to use shared examples with scope
  describe '.update_table_cache' do
    pending
  end

  describe '.wait_on_table_status' do
    pending
  end

  describe '.create_table' do
    it 'should create and delete a table' do

      valid_table_request = {
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
      }.freeze
      expect(TinyDyno::Adapter.create_table(valid_table_request)).to eq true
      expect(TinyDyno::Adapter.table_exists?(table_name: valid_table_request[:table_name])).to eq true
      expect(TinyDyno::Adapter.delete_table(table_name: valid_table_request[:table_name])).to eq true
    end
  end

  describe '.table_exists?' do

    it 'should return true, if a table exists' do
      valid_table_request = {
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
      }.freeze
      expect(TinyDyno::Adapter.create_table(valid_table_request)).to eq true
      expect(TinyDyno::Adapter.table_exists?(table_name: valid_table_request[:table_name])).to eq true
      expect(TinyDyno::Adapter.delete_table(table_name: valid_table_request[:table_name])).to eq true
    end

  end

  describe '.table_cache' do
    pending
  end



end