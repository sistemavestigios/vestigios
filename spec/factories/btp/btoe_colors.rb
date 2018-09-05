FactoryBot.define do
  factory :btp_color, class: 'Btp::Color' do
    hex_color '#ff0000'
    tag 'Cor'
    user { User.first || create(:user) }

    trait :with_comments do
      comments { [build(:btp_comment, comment: 'Comentário da cor', user_id: user.id)] }
    end

    trait :with_excerpts do
      text_ids { [Btp::Text.first.try(:id) || create(:btp_text).id] }
      excerpts { [build(:btp_excerpt, text_id: text_ids.first, user_id: user.id)] }
    end
  end
end
