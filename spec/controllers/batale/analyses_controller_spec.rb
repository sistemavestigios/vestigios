require 'rails_helper'

RSpec.describe Batale::AnalysesController, type: :controller do
  before(:example) do
    create(:batale_text, student_number: '1234')
    create(:batale_text, stratum_number: '03')
    create(:batale_text, collection_year: '2020')
    create(:batale_text, student_school: 'AB')
    create(:batale_text, collection_year: '2222')
    create(:batale_text, collection_year: '2211', normalized: 'chico abc123')
  end

  let(:valid_attributes) do
    { type_analyzed: 'Batale::Text',
      label: '',
      favorite: false,
      ids_analyzed: Batale::Text.pluck(:id),
      params_queried: { 'normalized' => 'chico', 'controller' => 'batale/texts' },
      user: @user }
  end

  let(:invalid_attributes) do
    { type_analyzed: '' }
  end

  before(:each) do
    @user = create(:user, :admin)
    sign_in @user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      request.session[:search_params] = valid_attributes[:params_queried]
      analysis = Analysis.create! valid_attributes
      get :show, params: { id: analysis.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Analysis' do
        expect {
          request.session[:search_params] = valid_attributes[:params_queried]
          post :create, params: { analysis: valid_attributes }
        }.to change(Analysis, :count).by(1)
      end

      it 'redirects to the created analysis' do
        request.session[:search_params] = valid_attributes[:params_queried]
        post :create, params: { analysis: valid_attributes }
        expect(response).to redirect_to(batale_analysis_path(Analysis.last, notice: I18n.t('success.create', model: Analysis.model_name.human)))
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { analysis: invalid_attributes }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_label) { 'New Label' }

      it 'updates the requested analysis label' do
        request.session[:search_params] = valid_attributes[:params_queried]
        analysis = Analysis.create! valid_attributes
        put :update, params: { id: analysis.to_param, label: new_label }
        analysis.reload
        expect(analysis.label).to eq(new_label)
      end

      it 'toggles the favorite option' do
        request.session[:search_params] = valid_attributes[:params_queried]
        analysis = Analysis.create! valid_attributes
        expect(analysis.favorite).to be(false)
        put :update, params: { id: analysis.to_param, favorite: true }
        analysis.reload
        expect(analysis.favorite).to be(true)
        put :update, params: { id: analysis.to_param, favorite: false }
        analysis.reload
        expect(analysis.favorite).to be(false)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested analysis' do
      request.session[:search_params] = valid_attributes[:params_queried]
      analysis = Analysis.create! valid_attributes
      expect {
        delete :destroy, params: { id: analysis.to_param }
      }.to change(Analysis, :count).by(-1)
    end

    it 'redirects to the analyses list' do
      request.session[:search_params] = valid_attributes[:params_queried]
      analysis = Analysis.create! valid_attributes
      delete :destroy, params: { id: analysis.to_param }
      expect(response).to redirect_to(batale_analyses_path)
    end
  end
end
