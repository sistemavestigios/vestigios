FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name Faker::Name.name
    password 'abc123'
    role  { Role.role_batale }

    trait :admin do
      role { Role.role_admin }
    end

    trait :btp do
      role { Role.role_btp }
    end
  end
end
