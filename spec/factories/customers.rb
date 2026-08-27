FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }
  end
end
