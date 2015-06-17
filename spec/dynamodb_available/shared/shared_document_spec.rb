require 'set'

shared_examples_for "tiny_dyno_document" do
  let(:validators) { described_class.new }

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

  it "does not respond to _destroy" do
    expect(validators).to_not respond_to(:_destroy)
  end

  context '.instance methods' do
    
    it 'should have access to ActiveModel::Conversion methods' do
      expect(validators.respond_to?(:to_key)).to be true
      expect(validators.respond_to?(:to_model)).to be true
      expect(validators.respond_to?(:to_param)).to be true
    end
  
    it 'should have access to ActiveModel::Validations' do
      expect(validators.respond_to?(:errors)).to be true
      expect(validators.respond_to?(:invalid?)).to be true
      expect(validators.respond_to?(:valid?)).to be true
      expect(validators.respond_to?(:validate)).to be true
      expect(validators.respond_to?(:validates_with)).to be true
    end
  
    it 'should have access to dirty methods' do
      expect(validators.respond_to?(:changed)).to be true
      expect(validators.respond_to?(:changed?)).to be true
      expect(validators.respond_to?(:changes)).to be true
      expect(validators.respond_to?(:previous_changes)).to be true
      expect(validators.respond_to?(:restore_attributes)).to be true
    end

  end

end