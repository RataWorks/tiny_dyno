$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'fabrication'
require 'faker'

require 'simplecov'
SimpleCov.coverage_dir 'coverage/rspec'

require 'tiny_dyno'

Dir.glob(File.join(ENV['PWD'],  'spec/models/*.rb')).each do |f|
  p "loading #{ f }"
  require f
end

Dir.glob(File.join(ENV['PWD'],  'spec/shared/*.rb')).each do |f|
  p "loading #{ f }"
  require f
end

if ENV['SNAP_CI'] == 'true'
  Aws.config[:endpoint] = 'http://127.0.0.1:8000'
else
  Aws.config[:endpoint] = 'http://172.17.42.1:8000'
end

RSpec.configure do |config|

  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

end

