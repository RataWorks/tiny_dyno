require 'set'

shared_examples_for "tiny_dyno_document" do
  let(:validators) { described_class.new }

  before(:all) do |example_group|
    described_class.delete_table
    described_class.create_table
  end
  after(:all) { described_class.delete_table }

  context 'table is available' do
    it 'should list the table in the table_cache' do
      expect(TinyDyno::Adapter.table_names.include?(described_class.table_name ) ).to be true
    end
  end

end