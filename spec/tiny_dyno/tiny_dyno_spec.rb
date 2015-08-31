require 'spec_helper'

describe TinyDyno do

  before(:each) { TinyDyno.instance_variable_set('@models', []) }
  it 'has a version number' do
    expect(TinyDyno::VERSION).not_to be nil
  end

  describe '.models' do

    it 'returns an empty array, when no model is defined' do
      expect(TinyDyno.models).to eq ([])
    end

    it 'returns the array of recently defined model names' do
      expect(TinyDyno.models).to eq ([])
      TinyDyno.register_model('Foo')
      TinyDyno.register_model('Bar')
      expect(TinyDyno.models).to eq (['Foo', 'Bar'])
    end

  end

  describe '.register_model' do

    it 'stores the name of a model' do
      expect(TinyDyno.register_model('foobar')).to eq (['foobar'])
    end
  end

end
