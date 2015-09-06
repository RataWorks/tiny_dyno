describe 'Array Field Test' do

  before(:each) {
    TestList.delete_table
    TestList.create_table
  }

  after(:each) {
    TestList.delete_table
  }

  let(:list) { Fabricate.build(:test_list) }

  it 'should save a document with an integer field' do
    list.names = {foo: 'bar'}
  end

end
