describe 'Boolean Field Test' do

  before(:each) {
    Account.delete_table
    Account.create_table
  }

  after(:each) {
    Account.delete_table
  }

  let(:my_account) { Fabricate.build(:account) }

  it 'should save a document with a boolean type' do
    expect([true,false].include?(my_account.active)).to be true
    expect(my_account.save).to be true
  end

  it 'should reject non boolean values on a boolean field' do
    expect { my_account.active = 'foobar' }.to raise_error TinyDyno::Errors::InvalidValueType
    expect { my_account.active = 0 }.to raise_error TinyDyno::Errors::InvalidValueType
    expect { my_account.active = 1 }.to raise_error TinyDyno::Errors::InvalidValueType
  end

  it 'permits nil, to allow field initialization, but raise errror' do
    expect(my_account.active = nil).to be nil
    expect(my_account.active.nil?).to be true
    expect { my_account.save }.to raise_error Aws::DynamoDB::Errors::ValidationException
  end

end
