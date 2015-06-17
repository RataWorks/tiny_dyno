require 'spec_helper'
require 'awesome_print'

Dir.glob(File.join(ENV['PWD'], 'spec/models/*.rb')).each  { |f| require f }

# read http://api.rubyonrails.org/classes/ActiveModel/AttributeMethods.html

describe TinyDyno::Document do

  context '.create_table' do

    before(:all) do |example|
      dynamodb_client = Aws::DynamoDB::Client.new
      table_names = dynamodb_client.list_tables.table_names
      table_names.each do |table_name|
        dynamodb_client.delete_table(table_name: table_name)
        dynamodb_client.wait_until(:table_not_exists, table_name: table_name)
      end
    end

    describe SmallPerson do
      it_behaves_like "tiny_dyno_document"
    end

  end

  context '#document' do
    let(:person) { SmallPerson.new }

    it 'should have access to ActiveModel::Conversion methods' do
      expect(person.respond_to?(:to_key)).to be true
      expect(person.respond_to?(:to_model)).to be true
      expect(person.respond_to?(:to_param)).to be true
    end

    it 'should have access to ActiveModel::Validations' do
      expect(person.respond_to?(:errors)).to be true
      expect(person.respond_to?(:invalid?)).to be true
      expect(person.respond_to?(:valid?)).to be true
      expect(person.respond_to?(:validate)).to be true
      expect(person.respond_to?(:validates_with)).to be true
    end

    it 'should have access to dirty methods' do
      expect(person.respond_to?(:changed)).to be true
      expect(person.respond_to?(:changed?)).to be true
      expect(person.respond_to?(:changes)).to be true
      expect(person.respond_to?(:previous_changes)).to be true
      expect(person.respond_to?(:restore_attributes)).to be true
    end

  end
end
