class Btp::ColorsController < ApplicationController
  before_action :set_btp_color, only: %i[show edit update destroy]
  before_action :set_breadcrumbs

  def index
    authorize @btp_colors = Btp::Color.all
  end

  def show; end

  def new
    authorize @btp_color = Btp::Color.new
  end

  def edit; end

  def create
    authorize @btp_color = Btp::Color.new(btp_color_params)
    @btp_color.user = current_user

    if request.referer.try(:include?, 'texts')
      render layout: false, format: :js
    elsif @btp_color.save
      redirect_to @btp_color, notice: t('success.create', model: Btp::Color.model_name.human)
    else
      render :new
    end
  end

  def update
    if request.referer.try(:include?, 'texts')
      render layout: false, format: :js
    elsif @btp_color.update(btp_color_params)
      redirect_to @btp_color, notice: t('success.update', model: Btp::Color.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @btp_color.destroy
    redirect_to btp_colors_url, notice: t('success.destroy', model: Btp::Color.model_name.human)
  end

  private

  def set_btp_color
    authorize @btp_color = Btp::Color.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb 'Início', dashboard_index_path
    add_breadcrumb Btp::Color.model_name.human(count: 2), btp_colors_path
    case action_name
    when 'show'
      add_breadcrumb @btp_color.name
    when 'edit'
      add_breadcrumb @btp_color.name, btp_color_path(@btp_color)
      add_breadcrumb 'Editando'
    end
  end

  def btp_color_params
    params
      .require(:btp_color)
      .permit(:hex_color, :tag,
        comments_attributes: Btp::Comment.permitted_attributes,
        excerpts_attributes: Btp::Excerpt.permitted_attributes)
  end
end
