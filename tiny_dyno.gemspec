# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tiny_dyno/version'

Gem::Specification.new do |spec|
  spec.name          = 'tiny_dyno'
  spec.version       = TinyDyno::VERSION
  spec.authors       = ['Tobias Gerschner']
  spec.email         = ['tobias.gerschner@rataworks.com']

  spec.summary       = %q{Minimum Interface to Amazon DynamoDB}
  spec.description   = %q{Minimum Interface to Amazon DynamoDB, heavily inspired by Mongoid.}
  spec.homepage      = 'https://github.com/rataworks/tiny_dyno'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to http://mygemserver.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'guard-rspec'

  spec.add_dependency 'aws-sdk', '~> 2.1'
  spec.add_dependency 'activemodel', '~> 4.2'

end
