require 'rails_helper'

RSpec.describe Batale::DefinitionsController, type: :controller do
  let(:valid_attributes) do
    { example: 'pessa', target_word: 'peça', rule: 'ç → ss' }
  end

  let(:invalid_attributes) do
    { example: nil }
  end

  before(:each) do
    @batale_errortog = create(:batale_errortog)
    @user = create(:user, :admin)
    sign_in @user
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Batale::Definition' do
        expect do
          post :create, params: { errortog_id: @batale_errortog, batale_definition: valid_attributes }
        end.to change(@batale_errortog.definitions, :count).by(1)
        expect(response).to redirect_to(batale_errortog_path(Batale::Definition.last.errortog_id))
      end
    end

    context 'with invalid params' do
      it 'doesnt create a Batale::Definition' do
        expect do
          post :create, params: { errortog_id: @batale_errortog, batale_definition: invalid_attributes }
          expect(response).to be_successful
        end.not_to change(@batale_errortog.definitions, :count)
        expect(assigns(:batale_definition)).to have(1).error_on(:example)
        expect(assigns(:batale_definition)).to have(1).error_on(:rule)
        expect(assigns(:batale_definition)).to have(1).error_on(:target_word)
      end
    end
  end

  describe 'PUT #update' do
    let(:definition) do
      create(:batale_definition, errortog: @batale_errortog)
    end

    context 'with valid params' do
      let(:new_attributes) do
        { example: 'outro example' }
      end

      let(:words_attributes) do
        { wrong: 'errada', right: 'correta', text_id: @text.id }
      end

      it 'updates the requested batale_definition' do
        put :update, params: {
          batale_definition: new_attributes,
          id: definition.to_param
        }
        definition.reload
        expect(definition.example).to eq('outro example')
        expect(response).to redirect_to(batale_definition_path(definition))
      end

      it 'updates the requested batale_definition adding a word to it' do
        @text = create(:batale_text)
        put :update, params: {
          batale_definition: new_attributes.merge(words_attributes: { '0' => words_attributes }),
          id: definition.to_param
        }
        expect(response).to redirect_to(batale_definition_path(definition))
        definition.reload
        @text.reload
        expect(definition.words.first.definition).to eq(definition)
        expect(definition.words.first.attributes && words_attributes).to eq(words_attributes)
        expect(definition.text_ids).to eq([@text.id])
        expect(@text.definition_ids).to eq([definition.id])
      end

      it 'updates the requested batale_definition removing a word from it' do
        definition = create(:batale_definition, :with_words)
        word = definition.words.first
        text = definition.texts.first
        put :update, params: {
          batale_definition: { words_attributes: { '0' => { id: word.to_param, _destroy: true } } },
          id: definition.to_param
        }
        expect(response).to redirect_to(batale_definition_path(definition))
        definition.reload
        expect(definition.words).to eq([])
        expect(definition.texts).to eq([])
        text.reload
        expect(text.definitions).to eq([])
      end
    end

    context 'with invalid params' do
      it 'renders edit again and adds errors on every invalid attribute' do
        put :update, params: { batale_definition: invalid_attributes, id: definition.to_param }
        expect(assigns(:batale_definition)).to have(1).error_on(:example)
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested batale_definition' do
      definition = create(:batale_definition)
      expect do
        delete :destroy, params: { errortog_id: definition.errortog, id: definition.to_param }
      end.to change(Batale::Definition, :count).by(-1)
      expect(response).to redirect_to(batale_errortog_path(Batale::Errortog.first))
    end
  end
end
