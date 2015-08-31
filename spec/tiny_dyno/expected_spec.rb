require 'spec_helper'

describe TinyDyno::Expected do

    describe '.request_as_new_record' do
      let(:person) { Fabricate.build(:person) }

      it 'does add expected clause' do
        expect(person.new_record?).to be true
        expect(person.request_as_new_record({})).to eq({:expected=>{:id=>{:comparison_operator=>"NULL"}}})
      end

    end

end