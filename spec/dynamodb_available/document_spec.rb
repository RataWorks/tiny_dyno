require 'spec_helper'
require 'awesome_print'

Dir.glob(File.join(ENV['PWD'], 'spec/models/*.rb')).each  { |f| require f }

# read http://api.rubyonrails.org/classes/ActiveModel/AttributeMethods.html

describe TinyDyno::Document do

  describe SmallPerson do
    it_behaves_like "tiny_dyno_document"
  end

end
