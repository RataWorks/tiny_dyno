require 'spec_helper'
require 'awesome_print'

Dir.glob(File.join(ENV['PWD'], 'spec/models/*.rb')).each  { |f| require f }

# read http://api.rubyonrails.org/classes/ActiveModel/AttributeMethods.html

describe TinyDyno::Document do

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
