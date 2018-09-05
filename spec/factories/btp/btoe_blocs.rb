FactoryBot.define do
  factory :btp_bloc, class: 'Btp::Bloc' do
    name 'Nome do bloco'
    description 'Descrição do bloco'
    user { User.first || create(:user) }

    trait :secret do
      secret true
    end

    trait :with_comments do
      comments { [build(:btp_comment, user_id: user.id)] }
    end

    trait :with_excerpts do
      text_ids { [Btp::Text.first.try(:id) || create(:btp_text).id] }
      excerpts { [build(:btp_excerpt, text_id: text_ids.first, user_id: user.id)] }
    end
  end
end
