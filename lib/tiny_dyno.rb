require 'active_model'

require 'tiny_dyno/version'
require 'tiny_dyno/errors/tiny_dyno_error'

require 'tiny_dyno/loggable'
require 'tiny_dyno/document'

module TinyDyno
  extend Loggable
  extend self

  # Register a model in the application with TinyDyno.
  #
  # @example Register a model.
  #   config.register_model(Band)
  #
  # @param [ Class ] klass The model to register.
  def register_model(klass)
    models.push(klass) unless models.include?(klass)
  end

  # Get all the models in the application - this is everything that includes
  # TinyDyno::Document.
  #
  # @example Get all the models.
  #   config.models
  #
  # @return [ Array<Class> ] All the models in the application.
  def models
    @models ||= []
  end

end
