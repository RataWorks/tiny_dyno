require 'set'

shared_examples_for "it is changeable" do
  let(:empty_doc) { described_class.new }
  let(:populated_doc) { Fabricate.build(described_class.to_s.downcase.to_sym) }

  describe '.changes' do
    it 'does return the changed attributes' do
      new_doc = Fabricate.build(described_class.to_s.downcase.to_sym)
      changes = {}
      new_doc.attributes.each do |k,v|
        next if k.nil?
        changes[k] = [empty_doc[k],v]
        empty_doc.send("#{k}=", v)
      end
      expect(new_doc.attributes == empty_doc.attributes).to eq true
      expect(empty_doc.changes.size).to eq (new_doc.attributes.size)
    end
  end
end
