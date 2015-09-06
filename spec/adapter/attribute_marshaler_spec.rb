describe TinyDyno::Adapter::AttributeValue do

  it 'should correctly construct string attributes' do
    expect(TinyDyno::Adapter.aws_attribute(field_type: String, value: 'foobar')).to eq({s: 'foobar'})
  end

  it 'should correctly construct string typed integer attributes' do
    expect(TinyDyno::Adapter.aws_attribute(field_type: Numeric, value: '5')).to eq({n: '5'})
  end

  it 'should correctly construct integer typed integer attributes' do
    expect(TinyDyno::Adapter.aws_attribute(field_type: Numeric, value: 5)).to eq({n: '5'})
  end

  it 'should correctly construct Hash attributes' do
    expect(TinyDyno::Adapter.aws_attribute(field_type: Hash, value: {foo: "bar"})).to eq({:m=>{"foo"=>{:s=>"bar"}}})
  end

end
