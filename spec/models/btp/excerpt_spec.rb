require 'rails_helper'

RSpec.describe Btp::Excerpt, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:excerpt) }
    it { is_expected.to validate_presence_of(:text_id) }
    it { is_expected.to validate_presence_of(:user_id) }

    it { is_expected.to embed_many(:comments) }

    it { is_expected.to be_embedded_in(:excerptable) }
  end
end
