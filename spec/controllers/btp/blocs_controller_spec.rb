require 'rails_helper'

RSpec.describe Btp::BlocsController, type: :controller do
  let(:valid_attributes) do
    { name: 'Meu Bloco', description: 'Descrição do meu bloco' }
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
      bloc = create(:btp_bloc)
      get :index
      expect(response).to be_successful
      expect(assigns(:btp_blocs).to_a).to eq([bloc])
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Btp::Bloc' do
        expect do
          post :create, params: { btp_bloc: valid_attributes }
        end.to change(Btp::Bloc, :count).by(1)
        expect(response).to redirect_to(Btp::Bloc.last)
      end
    end

    context 'with invalid params' do
      it 'renders new again and adds errors to btp bloc on every invalid attribute' do
        post :create, params: { btp_bloc: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:btp_bloc)).to have(1).error_on(:name)
      end
    end
  end

  describe 'PUT #update' do
    let(:bloc) { create(:btp_bloc) }

    context 'with valid params' do
      let(:new_attributes) do
        { description: 'Nova descrição' }
      end

      it 'updates the requested btp_bloc' do
        put :update, params: { id: bloc.to_param, btp_bloc: new_attributes }
        bloc.reload
        expect(bloc.description).to eq(new_attributes[:description])
        expect(response).to redirect_to(bloc)
      end

      context 'comments' do
        let(:comments_attributes) do
          { comment: 'Comentário do bloco', user_id: @user }
        end

        it 'updates the requested btp_bloc adding a comment to it' do
          put :update, params: { id: bloc.to_param, btp_bloc: { comments_attributes: { '0' => comments_attributes } } }
          expect(response).to redirect_to(bloc)
          bloc.reload
          expect(bloc.comments.first.attributes && comments_attributes).to eq(comments_attributes)
        end

        it 'adds a comment to a btp_bloc comment' do
          bloc = create(:btp_bloc, :with_comments)
          comment = bloc.comments.first
          user = create(:user, :btp)
          put :update, params: {
            id: bloc.to_param,
            btp_bloc: { comments_attributes: {
              '0' => {
                id: comment.to_param,
                child_comments_attributes: { '0' => { comment: 'Comentário de comentário', user_id: user } }
              }
            } }
          }
          expect(response).to redirect_to(bloc)
          comment.reload
          comment = comment.child_comments.first
          expect(comment.comment).to eq('Comentário de comentário')
          expect(comment.user).to eq(user)
        end

        it 'updates the requested btp_bloc removing a comment from it' do
          bloc = create(:btp_bloc, :with_comments)
          comment = bloc.comments.first
          put :update, params: {
            id: bloc.to_param,
            btp_bloc: { comments_attributes: { '0' => { id: comment, _destroy: true } } }
          }
          bloc.reload
          expect(bloc.comments).to eq([])
        end
      end

      context 'excerpts' do
        let(:excerpts_attributes) do
          { excerpt: 'Hoje nosso aluno, na grande maioria já tem um vasto...', text_id: @text, user_id: @user }
        end

        it 'updates the requested btp_bloc adding an excerpt to it' do
          @text = create(:btp_text)
          put :update, params: { id: bloc.to_param, btp_bloc: { excerpts_attributes: { '0' => excerpts_attributes } } }
          expect(response).to redirect_to(bloc)
          bloc.reload
          @text.reload
          expect(bloc.excerpts.first.attributes && excerpts_attributes).to eq(excerpts_attributes)
          expect(bloc.text_ids).to eq([@text.id])
          expect(@text.bloc_ids).to eq([bloc.id])
        end

        it 'adds a comment to a btp_bloc excerpt' do
          bloc = create(:btp_bloc, :with_excerpts)
          excerpt = bloc.excerpts.first
          user = create(:user, :btp)
          put :update, params: {
            id: bloc.to_param,
            btp_bloc: { excerpts_attributes: {
              '0' => {
                id: excerpt.to_param,
                comments_attributes: { '0' => { comment: 'Comentário de trecho', user_id: user } }
              }
            } }
          }
          expect(response).to redirect_to(bloc)
          excerpt.reload
          comment = excerpt.comments.first
          expect(comment.comment).to eq('Comentário de trecho')
          expect(comment.user).to eq(user)
        end

        it 'updates the requested btp_bloc removing an excerpt from it' do
          bloc = create(:btp_bloc, :with_excerpts)
          excerpt = bloc.excerpts.first
          text = bloc.texts.first
          put :update, params: {
            id: bloc.to_param,
            btp_bloc: { excerpts_attributes: { '0' => { id: excerpt.to_param, _destroy: true } } }
          }
          expect(response).to redirect_to(bloc)
          bloc.reload
          expect(bloc.excerpts).to eq([])
          expect(bloc.texts).to eq([])
          text.reload
          expect(text.blocs).to eq([])
        end
      end
    end

    context 'with invalid params' do
      it 'renders edit again and adds errors to btp bloc on every invalid attribute' do
        put :update, params: { id: bloc.to_param, btp_bloc: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:btp_bloc)).to have(1).error_on(:name)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested btp_bloc' do
      bloc = create(:btp_bloc)
      expect do
        delete :destroy, params: { id: bloc.to_param }
      end.to change(Btp::Bloc, :count).by(-1)
      expect(response).to redirect_to(btp_blocs_path)
    end
  end
end
