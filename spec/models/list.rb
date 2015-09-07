class TestList
  include TinyDyno::Document

  hash_key :id, type: String

  field :names, type: Array

end