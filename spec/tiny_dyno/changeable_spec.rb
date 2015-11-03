describe TinyDyno::Changeable do

  describe Person do
    it_behaves_like "it is changeable"
  end

  describe Person do

    it 'should accept the attribute value test' do

      p = Person.new
      p.first_name = 'test'
      expect(p.first_name).to eq ('test')

    end
  end



  end

end