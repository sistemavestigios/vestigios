require 'rails_helper'

RSpec.describe Btp::Bloc, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:secret) }

    it { is_expected.to embed_many(:comments) }
    it { is_expected.to embed_many(:excerpts) }

    it { is_expected.to accept_nested_attributes_for(:comments) }
    it { is_expected.to accept_nested_attributes_for(:excerpts) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_and_belong_to_many(:texts).of_type(Btp::Text) }
  end
end
