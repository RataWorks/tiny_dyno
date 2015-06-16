$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.coverage_dir 'coverage/rspec'

require 'tiny_dyno'

Dir.glob(File.join(ENV['PWD'],  'spec/models/*.rb')).each do |f|
  p "loading #{ f }"
  require f
end

RSpec.configure do |config|

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

end