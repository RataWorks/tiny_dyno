describe 'Integer Field Test' do

  let(:person) { Fabricate.build(:person) }

  describe 'Persistance' do

    before(:each) {
      Person.delete_table
      Person.create_table
    }

    after(:each) {
      Person.delete_table
    }

    it 'should retain and return the integer class of an integer value assignment' do
      person.age = 27
      expect(person.save).to be true
      expect(Person.where(id: person.id).age).to be 27
    end

    it 'should coerce a string number assignment to an integer field and return an Integer' do
      person.age = '55'
      expect(person.save).to be true
      expect(Person.where(id: person.id).age).to be 55
    end

  end

  describe 'Attribute Type Coercion' do

    it 'should retain and return the integer class of an integer value assignment' do
      expect(person.age = 27).to be 27
      expect(person.age).to be 27
    end

    it 'should coerce a string number assignment to an integer field and return an Integer' do
      expect(person.age = '55').to eq '55'
      expect(person.age).to be 55
    end

  end

  it 'should reject non coercable values on an integer field' do
    expect { person.age = 'foobar' }.to raise_error TinyDyno::Errors::InvalidValueType
  end

end
