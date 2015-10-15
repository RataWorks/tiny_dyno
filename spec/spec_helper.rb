$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

ENV['AWS_REGION'] ||= 'us-west-2'
ENV['AWS_ACCESS_KEY_ID'] ||= 'foo'
ENV['AWS_SECRET_ACCESS_KEY'] ||= 'bar'
ENV['DYNAMODB_URL'] ||= 'http://127.0.0.1:8000'

require 'pry'

require 'fabrication'
require 'faker'

require 'simplecov'
SimpleCov.coverage_dir 'coverage/rspec'

require 'aws-sdk'
Aws.config[:endpoint] = ENV['DYNAMODB_URL'] if ENV['DYNAMODB_URL']

require 'tiny_dyno'

Dir.glob(File.join(ENV['PWD'],  'spec/models/*.rb')).each do |f|
  p "loading #{ f }"
  require f
end

Dir.glob(File.join(ENV['PWD'],  'spec/shared/*.rb')).each do |f|
  p "loading #{ f }"
  require f
end

RSpec.configure do |config|

  config.run_all_when_everything_filtered = true
  config.order = :random

end

