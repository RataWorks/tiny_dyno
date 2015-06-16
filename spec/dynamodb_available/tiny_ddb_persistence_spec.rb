# require 'spec_helper'
# require 'awesome_print'
#
# Dir.glob(File.join(ENV['PWD'], 'spec/shared/*d_document_*.rb')).each  { |f| require f }
#
# describe 'Persistence' do
#
#   it 'should save a record' do
#     subject_c = ValidDocumentC.new
#     subject_c.name = 'My name is nobody'
#     binding.pry
#     expect(ValidDocumentC.create_table!).to eql true
#     expect(subject_s.save).to eql true
#     expect(ValidDocumentC.by_id('primary_key_value').attributes).to eq(@subject.attributes)
#   end
#
# end
