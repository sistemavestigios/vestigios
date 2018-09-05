require 'rails_helper'

RSpec.describe Batale::Text, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:student_number) }
    it { is_expected.to validate_presence_of(:student_age) }
    it { is_expected.to validate_presence_of(:student_sex) }
    it { is_expected.to validate_presence_of(:stratum_number) }
    it { is_expected.to validate_presence_of(:collection_number) }
    it { is_expected.to validate_presence_of(:student_text_number) }
    it { is_expected.to validate_presence_of(:collection_year) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:student_school) }
    it { is_expected.to validate_presence_of(:student_grade) }
    it { is_expected.to validate_presence_of(:student_class) }
    it { is_expected.to validate_presence_of(:original) }

    it { is_expected.to have_and_belong_to_many(:definitions).of_type(Batale::Definition) }

    it 'creates a code from text attributes' do
      text = create(:batale_text)
      expect(text.code).to eq('0001_070220_M_01_01_01_2001_TN_BA_1S_B')
    end
  end

  describe 'methods' do
    describe '.strata' do
      let(:two_strata) do
        [{ stratum_number: '01', count: 1 }, { stratum_number: '02', count: 1 }]
      end
      it 'returns an array of hashes of stratum number and count' do
        create(:batale_text)
        create(:batale_text, stratum_number: '02')
        strata = Batale::Text.strata_info
        expect(strata).to eq(two_strata)
      end
    end
  end
end
