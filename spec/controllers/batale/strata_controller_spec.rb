require 'rails_helper'

RSpec.describe Batale::StrataController, type: :controller do
  let(:valid_attributes) do
    {
      collected_material: 'Textos Espontâneos',
      collection_grades: '1ª a 4ª série do Ensino Fundamental',
      collection_type: 'Transversal e Longitudinal',
      collection_year: '2001-2004',
      quantity: 2024,
      region: 'Pelotas/RS/Brasil',
      schools: 'Pública e Particular – EMEF Bibiano de Almeida e Colégio Santa Margarida',
      stratum_number: '01'
    }
  end

  let(:invalid_attributes) do
    { collected_material: nil }
  end

  before(:each) do
    @user = create(:user, :admin)
    sign_in @user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      stratum = create(:batale_stratum)
      get :show, params: { id: stratum.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: {}
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      stratum = create(:batale_stratum)
      get :edit, params: { id: stratum.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Batale::Stratum' do
        expect do
          post :create, params: { batale_stratum: valid_attributes }
        end.to change(Batale::Stratum, :count).by(1)
      end

      it 'redirects to the created batale_stratum' do
        post :create, params: { batale_stratum: valid_attributes }
        expect(response).to redirect_to(Batale::Stratum.last)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { batale_stratum: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { collected_material: 'Textos Espontâneos e Ditados Balanceados' }
      end

      it 'updates the requested batale_stratum' do
        stratum = create(:batale_stratum)
        put :update, params: { id: stratum.to_param, batale_stratum: new_attributes }
        stratum.reload
        expect(stratum.collected_material).to eq('Textos Espontâneos e Ditados Balanceados')
      end

      it 'redirects to the batale_stratum' do
        stratum = create(:batale_stratum)
        put :update, params: { id: stratum.to_param, batale_stratum: valid_attributes }
        expect(response).to redirect_to(stratum)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'edit' template)" do
        stratum = create(:batale_stratum)
        put :update, params: { id: stratum.to_param, batale_stratum: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested batale_stratum' do
      stratum = create(:batale_stratum)
      expect do
        delete :destroy, params: { id: stratum.to_param }
      end.to change(Batale::Stratum, :count).by(-1)
    end

    it 'redirects to the batale_strata list' do
      stratum = create(:batale_stratum)
      delete :destroy, params: { id: stratum.to_param }
      expect(response).to redirect_to(batale_strata_url)
    end
  end
end
