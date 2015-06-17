require 'tiny_dyno/errors/tiny_dyno_error'

# Errors without guidance

class InvalidFieldOptionError < TinyDyno::Errors::TinyDynoError ; end
class InvalidTableDefinitionError < TinyDyno::Errors::TinyDynoError ; end
class InvalidHashKeyDefinitionError < TinyDyno::Errors::TinyDynoError ; end