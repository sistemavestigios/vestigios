require 'rails_helper'

RSpec.describe Btp::Text, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:teacher_number) }
    it { is_expected.to validate_presence_of(:region) }
    it { is_expected.to validate_presence_of(:full) }
    it { is_expected.to validate_presence_of(:class_number) }
    it { is_expected.to validate_presence_of(:acronym) }

    it { is_expected.to have_and_belong_to_many(:blocs).of_type(Btp::Bloc) }
    it { is_expected.to have_and_belong_to_many(:colors).of_type(Btp::Color) }
  end
end
