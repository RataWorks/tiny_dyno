require 'spec_helper'

describe TinyDyno::Attributes do

  context 'empty document' do

    let(:person) do
      Person.new
    end

    context 'return from' do
      it 'does return an empty hash' do
        expect(person.attributes).to eq({})
      end
      it 'does return nil on an empty attribute' do
        expect(person.first_name).to be nil
      end
    end

    context 'set attribute' do

      it 'does return the assigned attribute, with the correct class' do
        anton = person.first_name = 'anton'
        expect(anton).to eq('anton')
        expect(anton.class).to eq('anton'.class)
      end

      it 'assignes the attribute' do
        person.first_name= 'paul'
        expect(person.first_name).to eq('paul')
      end

      it 'casts an Integer to string' do
        person.first_name = 1234
        expect(person.first_name.class).to eq(String)
      end

      it 'does not set the attribute, if set with empty' do
        person.first_name = ''
        expect(person.first_name).to eq(nil)
      end

    end

  end
  context 'getting attributes on a populated model' do
    let(:peter_parker) do
      Person.new(first_name: 'peter', last_name: 'parker', age: 20)
    end

    it 'does return assigned attributes that are strings' do
      expect(peter_parker.first_name).to eq('peter')
      expect(peter_parker.last_name).to eq('parker')
    end
    it 'does return assigned attributes that are integers' do
      expect(peter_parker.age).to eq(20)
    end
  end


end