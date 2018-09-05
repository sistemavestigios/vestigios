require 'rails_helper'

RSpec.describe Btp::ColorsController, type: :controller do
  let(:valid_attributes) do
    { hex_color: '#ff0000', tag: 'tag' }
  end

  let(:invalid_attributes) do
    { hex_color: nil }
  end

  before(:each) do
    @user = create(:user, :admin)
    sign_in @user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      color = create(:btp_color)
      get :index
      expect(assigns(:btp_colors).to_a).to eq([color])
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Btp::Color' do
        expect do
          post :create, params: { btp_color: valid_attributes }
        end.to change(Btp::Color, :count).by(1)
        expect(response).to redirect_to(Btp::Color.last)
      end
    end

    context 'with invalid params' do
      it 'renders new again and adds errors to btp color on every invalid attribute' do
        post :create, params: { btp_color: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:btp_color)).to have(1).error_on(:hex_color)
      end
    end
  end

  describe 'PUT #update' do
    let(:color) { create(:btp_color) }

    context 'with valid params' do
      let(:new_attributes) do
        { tag: 'Nova tag' }
      end

      it 'updates the requested btp_color' do
        color = create(:btp_color)
        put :update, params: { id: color.to_param, btp_color: new_attributes }
        expect(response).to redirect_to(color)
        color.reload
        expect(color.tag).to eq(new_attributes[:tag])
      end

      context 'comments' do
        let(:comments_attributes) do
          { comment: 'Comentário da cor', user_id: @user }
        end

        it 'updates the requested btp_color adding a comment to it' do
          put :update, params: { id: color.to_param, btp_color: { comments_attributes: { '0' => comments_attributes } } }
          expect(response).to redirect_to(color)
          color.reload
          expect(color.comments.first.attributes && comments_attributes).to eq(comments_attributes)
        end

        it 'adds a comment to a btp_color comment' do
          color = create(:btp_color, :with_comments)
          comment = color.comments.first
          user = create(:user, :btp)
          put :update, params: {
            id: color.to_param,
            btp_color: { comments_attributes: {
              '0' => {
                id: comment.to_param,
                child_comments_attributes: { '0' => { comment: 'Comentário de comentário', user_id: user } }
              }
            } }
          }
          expect(response).to redirect_to(color)
          comment.reload
          comment = comment.child_comments.first
          expect(comment.comment).to eq('Comentário de comentário')
          expect(comment.user).to eq(user)
        end

        it 'updates the requested btp_color removing a comment from it' do
          color = create(:btp_color, :with_comments)
          comment = color.comments.first
          put :update, params: {
            id: color.to_param,
            btp_color: { comments_attributes: { '0' => { id: comment, _destroy: true } } }
          }
          color.reload
          expect(color.comments).to eq([])
        end
      end

      context 'excerpts' do
        let(:excerpts_attributes) do
          { excerpt: 'Hoje nosso aluno, na grande maioria já tem um vasto...', text_id: @text, user_id: @user }
        end

        it 'updates the requested btp_color adding an excerpt to it' do
          @text = create(:btp_text)
          put :update, params: { id: color.to_param, btp_color: { excerpts_attributes: { '0' => excerpts_attributes } } }
          expect(response).to redirect_to(color)
          color.reload
          @text.reload
          expect(color.excerpts.first.attributes && excerpts_attributes).to eq(excerpts_attributes)
          expect(color.text_ids).to eq([@text.id])
          expect(@text.color_ids).to eq([color.id])
        end

        it 'adds a comment to a btp_color excerpt' do
          color = create(:btp_color, :with_excerpts)
          excerpt = color.excerpts.first
          user = create(:user, :btp)
          put :update, params: {
            id: color.to_param,
            btp_color: { excerpts_attributes: {
              '0' => {
                id: excerpt.to_param,
                comments_attributes: { '0' => { comment: 'Comentário de trecho', user_id: user } }
              }
            } }
          }
          expect(response).to redirect_to(color)
          excerpt.reload
          comment = excerpt.comments.first
          expect(comment.comment).to eq('Comentário de trecho')
          expect(comment.user).to eq(user)
        end

        it 'updates the requested btp_color removing an excerpt from it' do
          color = create(:btp_color, :with_excerpts)
          excerpt = color.excerpts.first
          text = color.texts.first
          put :update, params: {
            id: color.to_param,
            btp_color: { excerpts_attributes: { '0' => { id: excerpt.to_param, _destroy: true } } }
          }
          expect(response).to redirect_to(color)
          color.reload
          expect(color.excerpts).to eq([])
          expect(color.texts).to eq([])
          text.reload
          expect(text.colors).to eq([])
        end
      end
    end

    context 'with invalid params' do
      it 'renders edit again and adds errors to btp color on every invalid attribute' do
        color = create(:btp_color)
        put :update, params: { id: color.to_param, btp_color: invalid_attributes }
        expect(response).to be_successful
        expect(assigns(:btp_color)).to have(1).error_on(:hex_color)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested btp_color' do
      color = create(:btp_color)
      expect do
        delete :destroy, params: { id: color.to_param }
      end.to change(Btp::Color, :count).by(-1)
      expect(response).to redirect_to(btp_colors_url)
    end
  end
end
