require 'rails_helper'

RSpec.describe Batale::ErrortogsController, type: :controller do
  let(:valid_attributes) do
    { name: 'Fonográfico' }
  end

  let(:invalid_attributes) do
    { name: nil }
  end

  before(:each) do
    @user = create(:user, :admin)
    sign_in @user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      errortog = create(:batale_errortog)
      get :index
      expect(response).to be_successful
      expect(assigns(:batale_errortogs).to_a).to eq([errortog])
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Batale::Errortog' do
        expect do
          post :create, params: { batale_errortog: valid_attributes }
        end.to change(Batale::Errortog, :count).by(1)
        expect(response).to redirect_to(Batale::Errortog.last)
      end

      it 'creates a new Batale::Errortog' do
        expect do
          post :create, params: {
            batale_errortog: valid_attributes.merge(
              definitions_attributes: {
                '0' => {
                  example: 'exemplo',
                  target_word: 'palavra alvo',
                  rule: 'regra'
                }
              }
            )
          }
        end.to change(Batale::Errortog, :count).by(1)
        expect(response).to redirect_to(Batale::Errortog.last)
        expect(Batale::Errortog.first.definitions.first.example).to eq('exemplo')
      end
    end

    context 'with invalid params' do
      it 'renders new again and adds errors to batale errortog on invalid attribute' do
        post :create, params: { batale_errortog: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:batale_errortog)).to have(1).error_on(:name)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { child_errortogs_attributes: { '0' => { name: 'Segmental' } } }
      end

      context 'with children' do
        it 'updates the requested batale_errortog adding a child' do
          errortog = create(:batale_errortog)
          put :update, params: { id: errortog.to_param, batale_errortog: new_attributes }
          expect(response).to redirect_to(errortog)
          errortog.reload
          expect(errortog.child_errortogs.first.name).to eq('Segmental')
        end

        it 'updates the requested batale_errortog removing a child' do
          errortog = create(:batale_errortog, :with_children)
          put :update, params: {
            id: errortog.to_param,
            batale_errortog: {
              child_errortogs_attributes: {
                '0' => {
                  id: errortog.child_errortogs.first.to_param,
                  _destroy: true
                }
              }
            }
          }
          expect(response).to redirect_to(errortog)
          errortog.reload
          expect(errortog.child_errortogs).to eq([])
        end
      end

      context 'with definitions' do
        it 'updates the requested batale_errortog adding a definition' do
          errortog = create(:batale_errortog)
          put :update, params: {
            id: errortog.to_param,
            batale_errortog: {
              definitions_attributes: {
                '0' => {
                  example: 'exemplo',
                  target_word: 'plavra alvo',
                  rule: 'regra'
                }
              }
            }
          }
          expect(response).to redirect_to(errortog)
          errortog.reload
          expect(errortog.definitions.first.example).to eq('exemplo')
        end
      end

      it 'updates the requested batale_errortog definition' do
        errortog = create(:batale_errortog, :with_definitions)
        put :update, params: {
          id: errortog.to_param,
          batale_errortog: { definitions_attributes: { '0' => { id: errortog.definitions.first.id, example: 'exemplo' } } }
        }
        expect(response).to redirect_to(errortog)
        errortog.reload
        expect(errortog.definitions.first.example).to eq('exemplo')
      end
    end

    context 'with invalid params' do
      it 'renders edit again and adds errors to batale errortog on invalid attribute' do
        errortog = create(:batale_errortog)
        put :update, params: { id: errortog.to_param, batale_errortog: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:batale_errortog)).to have(1).error_on(:name)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested batale_errortog' do
      errortog = create(:batale_errortog)
      expect do
        delete :destroy, params: { id: errortog.to_param }
      end.to change(Batale::Errortog, :count).by(-1)
      expect(response).to redirect_to(batale_errortogs_url)
    end
  end
end
