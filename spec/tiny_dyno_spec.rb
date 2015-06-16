require 'spec_helper'
require 'pry'


describe TinyDyno do
  it 'has a version number' do
    expect(TinyDyno::VERSION).not_to be nil
  end

  it 'registers models' do
    expect(TinyDyno.models.include?(MinimumModel)).to eql true
  end
end
