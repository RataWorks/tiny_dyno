describe 'DynamoDB Attribute unmarshaler' do

  it 'should correctly present a string attribute' do
    expect(TinyDyno::Adapter.doc_attribute({s: 'foobar'})).to eq('foobar')
  end

  it 'should correctly present an numeric attribute' do
    expect(TinyDyno::Adapter.doc_attribute({n: '5'})).to eq(5)
  end

  it 'should correctly present an integer attribute' do
    expect(TinyDyno::Adapter.doc_attribute({:m=>{"foo"=>{:s=>"bar"}}})).to eq({"foo"=>"bar"})
  end

end
