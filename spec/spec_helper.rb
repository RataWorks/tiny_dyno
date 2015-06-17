$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.coverage_dir 'coverage/rspec'

require 'tiny_dyno'
require 'awesome_print'

Dir.glob(File.join(ENV['PWD'],  'spec/models/*.rb')).each do |f|
  p "loading #{ f }"
  require f
end

Dir.glob(File.join(ENV['PWD'],  'spec/dynamodb_available/shared/*.rb')).each do |f|
  p "loading #{ f }"
  require f
end


ENV['AWS_ACCESS_KEY_ID'] ||= 'foobar'
ENV['AWS_SECRET_ACCESS_KEY'] ||= 'somedirtysecret'

if ENV['SNAP_CI'] == 'true'
  Aws.config.update({endpoint: 'http://127.0.0.1:8000'})
else
  Aws.config.update({endpoint: 'http://172.17.42.1:8000'})
end


RSpec.configure do |config|

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  dynamodb_client = Aws::DynamoDB::Client.new
  table_names = dynamodb_client.list_tables.table_names
  table_names.each do |table_name|
    dynamodb_client.delete_table(table_name: table_name)
    dynamodb_client.wait_until(:table_not_exists, table_name: table_name)
  end

  # config.order = 'random'

end