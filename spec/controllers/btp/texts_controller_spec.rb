require 'rails_helper'

RSpec.describe Btp::TextsController, type: :controller do
  let(:valid_attributes) do
    {
      acronym: 'alflet',
      year: 2013,
      region: 'pa',
      class_number: '12',
      teacher_number: '1',
      full: "Minha concepção de alfabetização?\nHoje nosso aluno, na grande maioria já tem um vasto"\
        "conhecimento informal aos 6 anos, mesmo que não domine /conheça o código.\n"\
        'Alfabetização é um sistema notacional, pois tem regras que precisam compreender p/ apropriar-se da'\
        " leitura e escrita.\nROSANE WIENANDTS"
    }
  end

  let(:invalid_attributes) do
    { acronym: nil }
  end

  before(:each) do
    @user = create(:user, :admin)
    sign_in @user
  end

  describe 'GET #index' do
    before(:each) do
      @text_thematic_ava = create(:btp_text, acronym: 'AVA')
      @text_thematic_cice = create(:btp_text, acronym: 'CICE')
    end

    it 'shows all thematics' do
      get :index
      expect(response).to be_successful
      expect(assigns(:thematics)).to eq([{ acronym: 'AVA', count: 1 }, { acronym: 'CICE', count: 1 }])
    end

    it 'only shows texts from selected thematic' do
      get :index, params: { acronym: 'AVA' }
      expect(response).to be_successful
      expect(assigns(:btp_texts).to_a).to eq([@text_thematic_ava])
    end

    describe 'search' do
      context 'with matching fields' do
        it 'only returns texts from thematics AVA and CICE' do
          text_thematic_hetotp = create(:btp_text, acronym: 'HETOTP')
          get :index, params: { acronym: %w[AVA CICE] }
          expect(response).to be_successful
          expect(assigns(:btp_texts).to_a).to eq([@text_thematic_ava, @text_thematic_cice])
          expect(assigns(:btp_texts).to_a).not_to include(text_thematic_hetotp)
        end

        it 'only shows texts from year 2014' do
          text2014 = create(:btp_text, year: 2014)
          get :index, params: { year: ['2014'] }
          expect(response).to be_successful
          expect(assigns(:btp_texts).to_a).to eq([text2014])
        end
      end

      context 'without matching fields' do
        it 'shows all available strata' do
          get :index, params: { acronym: 'LUDOTP' }
          expect(response).to be_successful
          expect(assigns(:batale_texts).to_a).to eq([])
          expect(assigns(:thematics)).to eq([{ acronym: 'AVA', count: 1 }, { acronym: 'CICE', count: 1 }])
        end
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Btp::Text' do
        expect do
          post :create, params: { btp_text: valid_attributes }
        end.to change(Btp::Text, :count).by(1)
        expect(response).to redirect_to(Btp::Text.last)
      end
    end

    context 'with invalid params' do
      it 'renders new again and adds errors to btp text on every invalid attribute' do
        post :create, params: { btp_text: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:btp_text)).to have(6).errors
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { acronym: 'hetotp' }
      end

      it 'updates the requested btp_text' do
        text = create(:btp_text)
        put :update, params: { id: text.to_param, btp_text: new_attributes }
        text.reload
        expect(text.acronym).to eq('hetotp')
        expect(text.code).to eq('HETOTP2013OT12-1')
        expect(response).to redirect_to(text)
      end
    end

    context 'with invalid params' do
      it 'renders edit again and add error to btp text on invalid attribute' do
        text = create(:btp_text)
        put :update, params: { id: text.to_param, btp_text: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:btp_text)).to have(1).error_on(:acronym)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested btp_text' do
      text = create(:btp_text)
      expect do
        delete :destroy, params: { id: text.to_param }
      end.to change(Btp::Text, :count).by(-1)
      expect(response).to redirect_to(btp_texts_path)
    end
  end
end
