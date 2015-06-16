describe TinyDyno::Document do
  context '.model' do

    describe '.model_table_exists?' do
      pending
    end


    describe '.(delete|create)table!' do

      it 'should create and delete the table as per model_definition' do
        expect(ValidDocumentB.create_table!).to eql true
        expect(ValidDocumentB.model_table_exists?).to eql true
        expect(ValidDocumentB.delete_table!).to eql true
      end

    end

  end
end