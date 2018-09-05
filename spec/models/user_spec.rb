require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:password) }

    it 'requires some attributes' do
      user = User.new
      expect(user.valid?).to be false
      expect(user).to have(1).error_on(:email)
      expect(user).to have(1).error_on(:name)
      expect(user).to have(1).error_on(:password)
      expect(user).to have(1).error_on(:role)
    end
  end

  describe 'methods' do
    before(:all) do
      @user = create(:user, :admin, name: 'Usuário do Sistema')
    end

    describe '.admin?' do
      context 'when admin' do
        it 'returns true' do
          expect(@user.admin?).to be true
        end
      end

      context 'with different role' do
        it 'returns false' do
          @user.role = Role.role_batale
          expect(@user.admin?).to be false
        end
      end
    end

    describe '.first_name' do
      it 'returns users first name' do
        expect(@user.first_name).to eq('Usuário')
      end
    end

    describe '.last_name' do
      it 'returns users last name' do
        expect(@user.last_name).to eq('Sistema')
      end
    end
  end
end
