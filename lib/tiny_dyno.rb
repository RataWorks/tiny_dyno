require 'active_support/inflector'
require 'active_model'
require 'aws-sdk'

require 'tiny_dyno/version'
require 'tiny_dyno/config'
require 'tiny_dyno/loggable'

require 'tiny_dyno/errors'

require 'tiny_dyno/document'

module TinyDyno
  extend Loggable
  extend self

  # Sets the TinyDyno configuration options. Best used by passing a block.
  #
  # @example Set up configuration options.
  #   TinyDyno.configure do |config|
  #     config.connect_to("tiny_dyno_test")
  #   end
  #
  # @return [ Config ] The configuration object.
  #
  # @since 1.0.0
  def configure
    block_given? ? yield(Config) : Config
  end

  # Take all the public instance methods from the Config singleton and allow
  # them to be accessed through the TinyDyno module directly.
  #

  # @since 1.0.0
  delegate(*(Config.public_instance_methods(false) - [ :logger=, :logger ] << { to: Config }))

end
