class Btoe::CommentsController < ApplicationController
  def destroy
    params.require(%i[id parent_class parent_id])
    if !params[:grandparent_id].nil?
      grandparent = params[:grandparent_class].constantize.find(params[:grandparent_id])
      parent = grandparent.excerpts.find(params[:parent_id])
      comment = parent.comments.find(params[:id])
      comment.destroy!
      parent.save!
      grandparent.save!
      redirect_to grandparent
    else
      parent = params[:parent_class].constantize.find(params[:parent_id])
      comment = parent.comments.find(params[:id])
      comment.destroy!
      parent.save!
      redirect_to parent
    end
  end

  def edit
    params.require(%i[comment_id edited_comment])
    if !params[:color_id].nil?
      color = Btoe::Color.find(params[:color_id])
      comment = color.comments.find(params[:comment_id])
      comment.comment = params[:edited_comment]
      comment.save!
      color.save!
    elsif !params[:bloc_id].nil?
      btoe_bloc = Btoe::Bloc.find(params[:bloc_id])
      comment = btoe_bloc.comments.find(params[:comment_id])
      comment.comment = params[:edited_comment]
      comment.save!
      btoe_bloc.save!
    end
  end
end
