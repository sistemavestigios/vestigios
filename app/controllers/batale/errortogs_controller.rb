class Batale::ErrortogsController < ApplicationController
  before_action :set_batale_errortog, only: %i[show edit update destroy]
  before_action :set_breadcrumbs

  def index
    authorize @batale_errortogs = Batale::Errortog.all
    @batale_definitions = Batale::Definition.search(params).page(params[:page] || 1).per(params[:per_page] || 5)
  end

  def show; end

  def new
    @batale_errortog = Batale::Errortog.new
  end

  def edit; end

  def create
    authorize @batale_errortog = Batale::Errortog.new(batale_errortog_params)

    if @batale_errortog.save
      redirect_to @batale_errortog, notice: t('success.create', model: Batale::Errortog.model_name.human)
    else
      render :new
    end
  end

  def update
    if @batale_errortog.update(batale_errortog_params)
      redirect_to @batale_errortog, notice: t('success.update', model: Batale::Errortog.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @batale_errortog.destroy
    redirect_to batale_errortogs_url, notice: t('success.destroy', model: Batale::Errortog.model_name.human)
  end

  private

  def set_batale_errortog
    authorize @batale_errortog = Batale::Errortog.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb 'Início', dashboard_index_path
    add_breadcrumb Batale::Errortog.model_name.human.pluralize, batale_errortogs_path
    @batale_errortog.parents.each { |p| add_breadcrumb p.name, batale_errortog_path(p) } if %w[show edit].include?(action_name)
    case action_name
    when 'show'
      add_breadcrumb @batale_errortog.name
    when 'edit'
      add_breadcrumb @batale_errortog.name, batale_errortog_path(@batale_errortog)
      add_breadcrumb 'Editando'
    end
  end

  def batale_errortog_params
    params
      .require(:batale_errortog)
      .permit(:name,
        child_errortogs_attributes: %i[id name _destroy],
        definitions_attributes: Batale::Definition.permitted_attributes)
  end
end
