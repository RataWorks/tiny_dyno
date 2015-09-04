class Person
  include TinyDyno::Document

  hash_key :id, type: String

  field :first_name, type: String
  field :last_name, type: String
  field :age, type: Integer

end