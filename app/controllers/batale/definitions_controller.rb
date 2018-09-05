class Batale::DefinitionsController < ApplicationController
  before_action :set_batale_definition, only: %i[show edit update destroy]
  before_action :set_batale_errortog, only: %i[create new]
  before_action :set_breadcrumbs

  def show
    @associated_texts = @batale_definition.search_associated_texts(params).page(params[:page] || 1).per(params[:per_page] || 5)
  end

  def new
    @batale_definition = Batale::Definition.new
  end

  def edit; end

  def create
    @batale_definition = @batale_errortog.definitions.build(batale_definition_params)

    if @batale_definition.save
      redirect_to batale_errortog_path(@batale_definition.errortog_id),
        notice: t('success.create', model: Batale::Definition.model_name.human)
    else
      render :new
    end
  end

  def update
    if @batale_definition.update(batale_definition_params)
      redirect_to batale_definition_path(@batale_definition),
        notice: t('success.update', model: Batale::Definition.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    batale_errortog = @batale_definition.errortog
    @batale_definition.destroy
    redirect_to batale_errortog_path(batale_errortog),
      notice: t('success.destroy', model: Batale::Definition.model_name.human)
  end

  private

  def action_specific_breadcrumbs
    case action_name
    when 'new'
      add_breadcrumb 'Novo Erro'
    when 'show'
      add_breadcrumb "Regra: #{@batale_definition.rule}"
    when 'edit'
      add_breadcrumb "Regra: #{@batale_definition.rule}", batale_definition_path(@batale_definition)
      add_breadcrumb 'Editando'
    end
  end

  def set_breadcrumbs
    add_breadcrumb 'Início', dashboard_index_path
    add_breadcrumb Batale::Errortog.model_name.human.pluralize, batale_errortogs_path
    @batale_errortog ||= @batale_definition.errortog
    @batale_errortog.parents.each { |p| add_breadcrumb p.name, batale_errortog_path(p) }
    add_breadcrumb @batale_errortog.name, batale_errortog_path(@batale_errortog)
    action_specific_breadcrumbs
  end

  def set_batale_definition
    authorize @batale_definition = Batale::Definition.find(params[:id])
  end

  def set_batale_errortog
    authorize @batale_errortog = Batale::Errortog.find(params[:errortog_id])
  end

  def batale_definition_params
    params
      .require(:batale_definition)
      .permit(:example, :target_word, :rule, :errortog_id,
        words_attributes: Batale::Word.permitted_attributes)
  end
end
