require 'rails_helper'

RSpec.describe Batale::TextsController, type: :controller do
  let(:valid_attributes) do
    {
      student_number: '0001',
      student_age: '071000',
      student_sex: 'M',
      stratum_number: 1,
      collection_number: 1,
      student_text_number: 1,
      collection_year: 2001,
      type: 'TN',
      student_school: 'BA',
      student_grade: '1S',
      student_class: 'B',
      original: "u chicuben to ta\nsentado na causa da\nboto agua nas flor\ndi pois ele\nfocinbora"
    }
  end

  let(:invalid_attributes) do
    { student_number: nil }
  end

  before(:each) do
    @user = create(:user, :admin)
    sign_in @user
  end

  describe 'GET #index' do
    before(:each) do
      @text_stratum1 = create(:batale_text, stratum_number: '01')
      @text_stratum2 = create(:batale_text, stratum_number: '02')
    end

    it 'shows all strata' do
      get :index
      expect(response).to be_successful
      expect(assigns(:strata_info)).to eq([{ stratum_number: '01', count: 1 }, { stratum_number: '02', count: 1 }])
    end

    it 'only shows texts from selected stratum' do
      get :index, params: { stratum_number: '02' }
      expect(response).to be_successful
      expect(assigns(:batale_texts).to_a).to eq([@text_stratum2])
    end

    describe 'search' do
      context 'with matching fields' do
        it 'only returns texts from stratum_numbers 01 and 02' do
          text_stratum3 = create(:batale_text, stratum_number: '03')
          get :index, params: { stratum_number: %w[01 02] }
          expect(response).to be_successful
          expect(assigns(:batale_texts).to_a).to eq([@text_stratum1, @text_stratum2])
          expect(assigns(:batale_texts).to_a).not_to include(text_stratum3)
        end

        it 'only shows texts from female students' do
          text_female_student = create(:batale_text, :female)
          get :index, params: { student_sex: ['F'] }
          expect(response).to be_successful
          expect(assigns(:batale_texts).to_a).to eq([text_female_student])
        end
      end

      context 'without matching fields' do
        it 'shows all available strata' do
          get :index, params: { stratum_number: '04' }
          expect(response).to be_successful
          expect(assigns(:batale_texts).to_a).to eq([])
          expect(assigns(:strata_info)).to eq([{ stratum_number: '01', count: 1 }, { stratum_number: '02', count: 1 }])
        end
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Batale::Text' do
        expect do
          post :create, params: { batale_text: valid_attributes }
        end.to change(Batale::Text, :count).by(1)
        expect(response).to redirect_to(Batale::Text.last)
      end
    end

    context 'with invalid params' do
      it 'renders new again and adds errors to batale text on every invalid attribute' do
        post :create, params: { batale_text: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:batale_text)).to have(12).errors
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          texto_normatizado: "o chico bento está\nsentado na calçada\nbotou água nas flores\ndepois ele\nfoi-se embora",
          tipo_escrita: 'Escrita pré-alfabética'
        }
      end

      it 'updates the requested batale_text' do
        text = create(:batale_text)
        put :update, params: { id: text.to_param, batale_text: new_attributes }
        expect(response).to redirect_to(text)
        text.reload
        expect(text.attributes && new_attributes).to eq(new_attributes)
      end
    end

    context 'with invalid params' do
      it 'renders edit again and add error to batale text on invalid attribute' do
        text = create(:batale_text)
        put :update, params: { id: text.to_param, batale_text: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:batale_text)).to have(1).error_on(:student_number)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested batale_text' do
      text = create(:batale_text)
      expect do
        delete :destroy, params: { id: text.to_param }
      end.to change(Batale::Text, :count).by(-1)
      expect(response).to redirect_to(batale_texts_url)
    end
  end
end
