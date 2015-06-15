# encoding: utf-8
require 'tiny_dyno/config/environment'
require 'tiny_dyno/config/options'
require 'tiny_dyno/config/validators'

module TinyDyno

  # This module defines all the configuration options for TinyDyno, including the
  # database connections.
  module Config
    extend Gem::Deprecate
    extend self
    extend Options

    delegate :logger=, to: ::TinyDyno
    delegate :logger, to: ::TinyDyno

    option :raise_not_found_error, default: true
    option :use_activesupport_time_zone, default: true
    option :use_utc, default: false

    # Load the settings from a compliant tiny_dyno.yml file. This can be used for
    # easy setup with frameworks other than Rails.
    #
    # @example Configure TinyDyno.
    #   TinyDyno.load!("/path/to/tiny_dyno.yml")
    #
    # @param [ String ] path The path to the file.
    # @param [ String, Symbol ] environment The environment to load.
    #
    def load!(path, environment = nil)
      settings = Environment.load_yaml(path, environment)
      if settings.present?
        load_configuration(settings)
      end
      settings
    end

    # Set the configuration options. Will validate each one individually.
    #
    # @example Set the options.
    #   config.options = { raise_not_found_error: true }
    #
    # @param [ Hash ] options The configuration options.
    #
    # @since 3.0.0
    def options=(options)
      if options
        options.each_pair do |option, value|
          Validators::Option.validate(option)
          send("#{option}=", value)
        end
      end
    end
    # From a hash of settings, load all the configuration.
    #
    # @example Load the configuration.
    #   config.load_configuration(settings)
    #
    # @param [ Hash ] settings The configuration settings.
    def load_configuration(settings)
      configuration = settings
      self.options = configuration[:options]
    end
  end
end
