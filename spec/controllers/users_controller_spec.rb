require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_attributes) do
    {
      email: Faker::Internet.email,
      name: Faker::Name.name,
      password: 'abc123',
      password_confirmation: 'abc123',
      role_id: Role.role_batale
    }
  end

  let(:invalid_attributes) do
    { email: Faker::Internet.email, name: Faker::Name.name }
  end

  before(:each) do
    @user = create(:user)
    @admin_user = create(:user, :admin)
  end

  describe 'POST #create' do
    context 'when not admin' do
      it 'cant create a new user' do
        sign_in @user
        expect do
          post :create, params: { user: valid_attributes }
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when admin' do
      before(:each) do
        sign_in @admin_user
      end

      context 'with valid attributes' do
        it 'creates a new user' do
          expect do
            post :create, params: { user: valid_attributes }
          end.to change(User, :count).by(1)
        end
      end

      context 'with invalid attributes' do
        it 'renders new again and shows errors' do
          expect do
            post :create, params: { user: invalid_attributes }
          end.not_to change(User, :count)
          expect(response).to be_successful
          expect(assigns(:user)).to have(1).error_on(:password)
          expect(assigns(:user)).to have(1).error_on(:role)
        end
      end
    end
  end

  describe 'PUT #update' do
    context 'when not admin' do
      it 'can change own attributes' do
        sign_in @user
        put :update, params: { id: @user, user: { name: 'Novo Nome' } }
        expect(response).to redirect_to(root_path)
        @user.reload
        expect(@user.name).to eq('Novo Nome')
      end

      it 'cant change own role' do
        sign_in @user
        put :update, params: { id: @user, user: { role_id: Role.role_btp } }
        @user.reload
        expect(@user.role).to eq(Role.role_batale)
      end

      it 'cant change other users attributes' do
        sign_in @user
        expect do
          put :update, params: { id: @admin_user, user: { name: 'Novo Nome' } }
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when admin' do
      it 'can change other users attributes' do
        sign_in @admin_user
        put :update, params: { id: @user.id, user: { name: 'Novo Nome', role_id: Role.role_btp } }
        expect(response).to redirect_to(root_path)
        @user.reload
        expect(@user.name).to eq('Novo Nome')
        expect(@user.role).to eq(Role.role_btp)
      end

      it 'cant change own role' do
        sign_in @admin_user
        put :update, params: { id: @admin_user.id, user: { role_id: Role.role_btp } }
        expect(response).to redirect_to(root_path)
        @admin_user.reload
        expect(@admin_user.role).to eq(Role.role_admin)
      end
    end
  end
end
