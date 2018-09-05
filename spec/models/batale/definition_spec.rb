require 'rails_helper'

RSpec.describe Batale::Definition, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:errortog).of_type(Batale::Errortog) }
    it { is_expected.to validate_presence_of(:example) }
    it { is_expected.to validate_presence_of(:rule) }
    it { is_expected.to validate_presence_of(:target_word) }

    it { is_expected.to have_and_belong_to_many(:texts).of_type(Batale::Text) }
    it { is_expected.to embed_many(:words) }
    it { is_expected.to accept_nested_attributes_for(:words) }
  end

  describe '.errortog' do
    before(:each) do
      @errortog = create(:batale_errortog)
      @other_errortog = create(:batale_errortog)
      @definition = create(:batale_definition, errortog: @errortog)
    end

    it 'finds the definitions errortog' do
      expect(@definition.errortog).to eq(@errortog)
      expect(@definition.errortog).not_to eq(@other_errortog)
    end
  end
end
