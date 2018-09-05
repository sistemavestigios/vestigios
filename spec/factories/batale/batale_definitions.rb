FactoryBot.define do
  factory :batale_definition, class: 'Batale::Definition' do
    errortog { Batale::Errortog.first || create(:batale_errortog) }
    example 'pessa'
    rule 'ç → ss'
    target_word 'peça'

    trait :with_words do
      text_ids { [Batale::Text.first.try(:id) || create(:batale_text).id] }
      words { [build(:batale_word, text_id: text_ids.first)] }
    end
  end

  factory :batale_word, class: 'Batale::Word' do
    wrong 'chicuben to'
    right 'chico bento'
  end
end
