class Btp::BlocsController < ApplicationController
  before_action :set_btp_bloc, only: %i[show edit update destroy]
  before_action :set_breadcrumbs

  def index
    authorize @btp_blocs = Btp::Bloc.all
  end

  def show; end

  def new
    authorize @btp_bloc = Btp::Bloc.new
  end

  def edit; end

  def create
    authorize @btp_bloc = Btp::Bloc.new(btp_bloc_params)
    @btp_bloc.user = current_user

    if request.referer.try(:include?, 'texts')
      render layout: false, format: :js
    elsif @btp_bloc.save
      redirect_to @btp_bloc, notice: t('success.create', model: Btp::Bloc.model_name.human)
    else
      render :new
    end
  end

  def update
    if request.referer.try(:include?, 'texts')
      render layout: false, format: :js
    elsif @btp_bloc.update(btp_bloc_params)
      redirect_to @btp_bloc, notice: t('success.update', model: Btp::Bloc.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @btp_bloc.destroy
    redirect_to btp_blocs_url, notice: t('success.destroy', model: Btp::Bloc.model_name.human)
  end

  private

  def set_breadcrumbs
    add_breadcrumb 'Início', dashboard_index_path
    add_breadcrumb Btp::Bloc.model_name.human.pluralize, btp_blocs_path
    case action_name
    when 'show'
      add_breadcrumb @btp_bloc.name
    when 'edit'
      add_breadcrumb @btp_bloc.name, btp_bloc_path(@btp_bloc)
      add_breadcrumb 'Editando'
    end
  end

  def set_btp_bloc
    authorize @btp_bloc = Btp::Bloc.find(params[:id])
  end

  def btp_bloc_params
    params
      .require(:btp_bloc)
      .permit(:description, :name, :secret,
        comments_attributes: Btp::Comment.permitted_attributes,
        excerpts_attributes: Btp::Excerpt.permitted_attributes)
  end
end
