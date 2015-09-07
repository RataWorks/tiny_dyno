describe 'Array Field Test' do

  before(:each) {
    TestList.delete_table
    TestList.create_table
  }

  after(:each) {
    TestList.delete_table
  }

  let(:list) { Fabricate.build(:test_list) }

  it 'should save a document with an array field' do
    list.names = ['foo', 'bar']
    expect(list.save).to be true
    expect(TestList.where(id: list.id).names).to eq(['foo', 'bar'])
  end

end
