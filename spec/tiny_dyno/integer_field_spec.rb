describe 'Integer Field Test' do

  before(:each) {
    Person.delete_table
    Person.create_table
  }

  after(:each) {
    Person.delete_table
  }

  let(:person) { Fabricate.build(:person) }

  it 'should save a document with an integer field' do
    person.age = 27
    expect(person.age).to be 27
    expect(person.save).to be true
  end

  it 'should save a document with an integer field, cast as String' do
    person.age = '55'
    expect(person.age).to be 55
    expect(person.save).to be true
    expect(Person.where(id: person.id).age).to be 55
  end

  it 'should reject non coercable values on an integer field' do
    expect { person.age = 'foobar' }.to raise_error TinyDyno::Errors::InvalidValueType
  end

end
