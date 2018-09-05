FactoryBot.define do
  factory :batale_errortog, class: 'Batale::Errortog' do
    name 'Fonológico'

    trait :with_children do
      child_errortogs { [build(:batale_errortog, name: 'Segmental')] }
    end

    trait :with_definitions do
      after(:create) do |errortog, _evaluator|
        create(:batale_definition, errortog: errortog)
      end
    end
  end
end
