require 'spec_helper'
require 'awesome_print'

describe TinyDyno::Document do

  describe Person do
    it_behaves_like "tiny_dyno_document"

  end

  describe ".included" do

    let(:models) do
      TinyDyno.models
    end

    let(:new_klass_name) do
      'NewKlassName'
    end

    let(:new_klass) do
      Class.new do
        class << self; attr_accessor :name; end
      end.tap{|new_klass| new_klass.name = new_klass_name}
    end

    let(:new_model) do
      new_klass.tap do
        new_klass.send(:include, ::TinyDyno::Document)
      end
    end

    let(:twice_a_new_model) do
      new_klass.tap do
        2.times{ new_klass.send(:include, ::TinyDyno::Document) }
      end
    end

    context "before Document has been included" do
      it ".models should *not* include that model" do
        expect(models).to_not include(new_klass)
      end
    end

    context "after Document has been included" do
      it ".models should include that model" do
        expect(models).to include(new_model)
      end
    end

    context "after Document has been included multiple times" do
      it ".models should include that model just once" do
        expect(models.count(twice_a_new_model)).to be_eql(1)
      end
    end
  end

end
