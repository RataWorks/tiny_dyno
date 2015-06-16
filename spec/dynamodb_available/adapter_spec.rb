require 'spec_helper'

describe TinyDyno::Adapter do

  context 'lazy connection' do
    before(:all) { TinyDyno::Adapter.disconnect! }
    it 'should lazily establish a connection' do
      TinyDyno::Adapter.update_table_cache
      expect(TinyDyno::Adapter.connected?).to eql true
    end
  end

  context 'connected' do

    describe 'connect' do
      it 'should connect to DynamoDB' do
        expect(TinyDyno::Adapter.connect).to be true
      end
    end

    describe '.connected?' do

      it 'should return true, if a connection to dynamodb exists' do
        TinyDyno::Adapter.connect
        expect(TinyDyno::Adapter.connected?).to eql true
      end

      it 'should return false, if a connection to dynamodb does not exists' do
        expect(TinyDyno::Adapter.connected?).to eql true
        TinyDyno::Adapter.disconnect!
        expect(TinyDyno::Adapter.connected?).to eql false
      end

    end
  end

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
      expect(TinyDyno::Adapter.create_table(valid_table_request)).to eql true
      expect(TinyDyno::Adapter.table_exists?(table_name: valid_table_request[:table_name])).to eql true
      expect(TinyDyno::Adapter.delete_table(table_name: valid_table_request[:table_name])).to eql true
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
      expect(TinyDyno::Adapter.create_table(valid_table_request)).to eql true
      expect(TinyDyno::Adapter.table_exists?(table_name: valid_table_request[:table_name])).to eql true
      expect(TinyDyno::Adapter.delete_table(table_name: valid_table_request[:table_name])).to eql true
    end

  end

  describe '.table_cache' do
    pending
  end

end
