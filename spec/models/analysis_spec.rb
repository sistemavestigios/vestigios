require 'rails_helper'

RSpec.describe Analysis, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:ids_analyzed) }
    it { is_expected.to validate_presence_of(:params_queried) }
    it { is_expected.to validate_presence_of(:type_analyzed) }

    it { is_expected.to belong_to(:user) }
  end
end
