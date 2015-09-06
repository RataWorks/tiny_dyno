Fabricator(:test_list) do
  id { SecureRandom.uuid }
  names { {"#{ Faker::Name.first_name }" => "#{ Faker::Name.last_name }"} }
end