require 'set'

shared_examples_for "tiny_dyno_doc" do
  let(:tables) { described_class.new }

  before(:all) { described_class.create_table! }

  context 'table is available' do
    it 'should list the table in the table_cache' do
      expect(TinyDyno::Adapter.table_names.include?(described_class.table_name ) )

    end
  end

end