require 'set'

shared_examples_for "tiny_dyno_document" do
  let(:empty_doc) { described_class.new }
  let(:populated_doc) { Fabricate.build(described_class.to_s.downcase.to_sym) }

  it "does not respond to _destroy" do
    expect(empty_doc).to_not respond_to(:_destroy)
  end

  it 'should have access to ActiveModel::Conversion methods' do
    expect(empty_doc.respond_to?(:to_key)).to be true
    expect(empty_doc.respond_to?(:to_model)).to be true
    expect(empty_doc.respond_to?(:to_param)).to be true
  end

  it 'should have access to ActiveModel::Validations' do
    expect(empty_doc.respond_to?(:errors)).to be true
    expect(empty_doc.respond_to?(:invalid?)).to be true
    expect(empty_doc.respond_to?(:valid?)).to be true
    expect(empty_doc.respond_to?(:validate)).to be true
    expect(empty_doc.respond_to?(:validates_with)).to be true
  end

  it 'should have access to dirty methods' do
    expect(empty_doc.respond_to?(:changed)).to be true
    expect(empty_doc.respond_to?(:changed?)).to be true
    expect(empty_doc.respond_to?(:changes)).to be true
    expect(empty_doc.respond_to?(:previous_changes)).to be true
    expect(empty_doc.respond_to?(:restore_attributes)).to be true
  end

  it 'can be instantiated without attributes' do
    expect(described_class.new.class).to eq (described_class)
    expect(described_class.new.attributes).to eq ({})
  end

  context '#instance' do

    it 'should be instantiated with populated attributes' do
      expect(populated_doc.attributes.nil?).to be false
    end

  end

end