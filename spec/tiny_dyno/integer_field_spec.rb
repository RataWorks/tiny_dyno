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

  end

  describe 'Attribute Type Coercion' do

    it 'should retain and return the integer class of an integer value assignment' do
      expect(person.age = 27).to be 27
      expect(person.age).to be 27
    end

    it 'does coerce string typed numbers' do
      expect(person.age = '234').to eq '234'
      expect(person.age).to be 234
    end

    it 'should reject string numbers, not easily convertable' do
      expect { person.age = '00' }.to raise_error TinyDyno::Errors::NotTransparentlyCoercible
    end

    it 'should reject non coercable values on an integer field' do
      expect { person.age = 'foobar' }.to raise_error TinyDyno::Errors::NotTransparentlyCoercible
    end

  end

end
