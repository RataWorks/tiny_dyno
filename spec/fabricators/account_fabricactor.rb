Fabricator(:account) do
  email { Faker::Internet.email }
  label { Faker::Lorem.words.join(' ')}
end