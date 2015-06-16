require "spec_helper"

describe TinyDyno::Document do

  let(:klass) do
    SmallPerson
  end

  let(:person) do
    SmallPerson.new
  end

  it "does not respond to _destroy" do
    expect(person).to_not respond_to(:_destroy)
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

    context "when Document has been included in a model" do
      it ".models should include that model" do
        expect(models).to include(klass)
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

  describe "._types" do


    context "when the document is not subclassed" do

      let(:types) do
        Address._types
      end

      it "returns the document" do
        expect(types).to eq([ "Address" ])
      end
    end

  end

  describe "#initialize" do

    let(:person) do
      SmallPerson.new(title: "Sir")
    end

    it "sets the attributes" do
      expect(person.title).to eq("Sir")
    end

    context "when defaults are defined" do

      it "sets the default values" do
        expect(person.age).to eq(100)
      end
    end

    context "when a block is provided" do

      let(:person) do
        SmallPerson.new do |doc|
          doc.title = "King"
        end
      end

      it "yields to the block" do
        expect(person.title).to eq("King")
      end
    end
  end

  describe ".instantiate" do

    context "when passing a block" do

      let(:document) do
        Band.instantiate("_id" => id, "name" => "Depeche Mode") do |band|
          band.likes = 1000
        end
      end

      it "yields to the block" do
        expect(document.likes).to eq(1000)
      end
    end

    context "when an id exists" do

      let!(:person) do
        SmallPerson.instantiate("_id" => id, "title" => "Sir")
      end

      it "sets the attributes" do
        expect(person.title).to eq("Sir")
      end

      # it "sets persisted to true" do
      #   expect(person).to be_persisted
      # end
    end

    context "when attributes are nil" do

      let(:person) do
        SmallPerson.instantiate
      end

      it "creates a new document" do
        expect(person).to be_a(SmallPerson)
      end
    end
  end

  describe "#model_name" do

    let(:person) do
      SmallPerson.new
    end

    it "returns the class model name" do
      expect(person.model_name).to eq("SmallPerson")
    end
  end

  # TODO, this should return the DynamoDB attribute structure
  # describe "#raw_attributes" do
  #
  #   let(:person) do
  #     SmallPerson.new(title: "Sir")
  #   end
  #
  #   it "returns the internal attributes" do
  #     expect(person.raw_attributes["title"]).to eq("Sir")
  #   end
  # end

  describe "#to_a" do

    let(:person) do
      SmallPerson.new
    end

    let(:people) do
      person.to_a
    end

    it "returns the document in an array" do
      expect(people).to eq([ person ])
    end
  end

  describe "#as_document" do

    let!(:person) do
      SmallPerson.new(title: "Sir")
    end

    let!(:address) do
      person.addresses.build(street: "Upper")
    end

    let!(:name) do
      person.build_name(first_name: "James")
    end

    let!(:location) do
      address.locations.build(name: "Home")
    end


    context "when removing an embedded document" do

      before do
        person.save
        person.addresses.delete(address)
      end

      it "does not include the document in the hash" do
        expect(person.as_document["addresses"]).to be_empty
      end
    end

  end

  describe "#to_key" do

    context "when the document is new" do

      let(:person) do
        SmallPerson.new
      end

      it "returns nil" do
        expect(person.to_key).to be_nil
      end
    end

    context "when the document is not new" do

      let(:person) do
        SmallPerson..build
      end

      it "returns the id in an array" do
        expect(person.to_key).to eq([ person.id.to_s ])
      end

      it "can query using the key" do
        expect(person.id).to eq SmallPerson.find(person.to_key).first.id
      end
    end

    context "when the document is destroyed" do

      let(:person) do
        SmallPerson.instantiate("_id" => 1.new).tap do |peep|
          peep.destroyed = true
        end
      end

      it "returns the id in an array" do
        expect(person.to_key).to eq([ person.id.to_s ])
      end
    end
  end

  describe "#to_param" do

    context "when the document is new" do

      let(:person) do
        SmallPerson.new
      end

      it "returns nil" do
        expect(person.to_param).to be_nil
      end
    end

    context "when the document is not new" do

      let(:person) do
        SmallPerson.instantiate("_id" => 1.new)
      end

      it "returns the id as a string" do
        expect(person.to_param).to eq(person.id.to_s)
      end
    end
  end

  describe "#frozen?" do

    let(:person) do
      SmallPerson.new
    end

    context "when attributes are not frozen" do

      it "return false" do
        expect(person).to_not be_frozen
        expect {
          person.title = "something"
        }.to_not raise_error
      end
    end

    context "when attributes are frozen" do
      before do
        person.raw_attributes.freeze
      end

      it "return true" do
        expect(person).to be_frozen
      end
    end
  end

  describe "#freeze" do

    let(:person) do
      SmallPerson.new
    end

    context "when not frozen" do

      it "freezes attributes" do
        expect(person.freeze).to eq(person)
        expect { person.title = "something" }.to raise_error
      end
    end

    context "when frozen" do

      before do
        person.raw_attributes.freeze
      end

      it "keeps things frozen" do
        person.freeze
        expect {
          person.title = "something"
        }.to raise_error
      end
    end
  end

  describe ".logger" do

    it "returns the TinyDyno logger" do
      expect(SmallPerson.logger).to eq(TinyDyno.logger)
    end
  end

  describe "#logger" do

    let(:person) do
      SmallPerson.new
    end

    it "returns the TinyDyno logger" do
      expect(person.send(:logger)).to eq(TinyDyno.logger)
    end
  end

  context "when a model name conflicts with a TinyDyno internal" do

    let(:scheduler) do
      Scheduler.new
    end

    it "allows the model name" do
      expect(scheduler.strategy).to be_a(Strategy)
    end
  end

  describe "#initialize" do

    context "when providing a block" do

      it "sets the defaults before yielding" do
        SmallPerson.new do |person|
          expect(person.age).to eq(100)
        end
      end
    end
  end

  context "creating anonymous documents" do

    context "when defining collection" do

      let(:model) do
        Class.new do
          include TinyDyno::Document
          store_in collection: "anonymous"
          field :gender
        end
      end

      it "allows the creation" do
        Object.const_set "Anonymous", model
      end
    end
  end

  describe "#becomes" do

    before(:all) do
      SmallPerson.validates_format_of(:ssn, without: /\$\$\$/)

      class Manager < SmallPerson
        field :level, type: Integer, default: 1
      end
    end

    after(:all) do
      SmallPerson.reset_callbacks(:validate)
      Object.send(:remove_const, :Manager)
    end

  end

  context "when marshalling the document" do

    let(:person) do
      SmallPerson.new.tap do |person|
        person.addresses.extension
      end
    end

    let!(:account) do
      person.create_account(name: "savings")
    end

    describe Marshal, ".dump" do

      it "successfully dumps the document" do
        expect {
          Marshal.dump(person)
          Marshal.dump(account)
        }.not_to raise_error
      end
    end

    describe Marshal, ".load" do

      it "successfully loads the document" do
        expect { Marshal.load(Marshal.dump(person)) }.not_to raise_error
      end
    end
  end

  context "when putting a document in the cache" do

    describe ActiveSupport::Cache do

      let(:cache) do
        ActiveSupport::Cache::MemoryStore.new
      end

      describe "#fetch" do

        let!(:person) do
          SmallPerson.new
        end

        let!(:account) do
          person.create_account(name: "savings")
        end

        it "stores the parent object" do
          expect(cache.fetch("key") { person }).to eq(person)
          expect(cache.fetch("key")).to eq(person)
        end

        it "stores the embedded object" do
          expect(cache.fetch("key") { account }).to eq(account)
          expect(cache.fetch("key")).to eq(account)
        end
      end
    end
  end
end
