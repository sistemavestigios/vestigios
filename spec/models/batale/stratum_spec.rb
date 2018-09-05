require 'rails_helper'

RSpec.describe Batale::Stratum, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:collected_material) }
    it { is_expected.to validate_presence_of(:collection_grades) }
    it { is_expected.to validate_presence_of(:collection_type) }
    it { is_expected.to validate_presence_of(:collection_year) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:region) }
    it { is_expected.to validate_presence_of(:schools) }
    it { is_expected.to validate_presence_of(:stratum_number) }
  end
end
