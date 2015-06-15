$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.coverage_dir 'coverage/rspec'

require 'tiny_dyno'
