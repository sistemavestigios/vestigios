require 'rails_helper'

RSpec.describe Btp::Comment, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:comment) }
    it { is_expected.to validate_presence_of(:user_id) }

    it { is_expected.to be_embedded_in(:commentable) }
  end
end
