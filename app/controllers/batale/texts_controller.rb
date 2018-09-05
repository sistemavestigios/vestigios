class Batale::TextsController < ApplicationController
  before_action :set_batale_text, only: %i[show edit update destroy]
  before_action :set_breadcrumbs

  def index
    authorize @batale_texts = Batale::Text.search(params)
    session[:search_params] = request.params
    @batale_texts = @batale_texts.page(params[:page] || 1).per(params[:per_page] || 5)
    @strata = Batale::Stratum.all.group_by(&:stratum_number)
    @strata_info = Batale::Text.strata_info
    session[:search_params] = request.query_parameters
  end

  def show
    next_and_previous_texts
  end

  def new
    authorize @batale_text = Batale::Text.new
  end

  def edit; end

  def create
    authorize @batale_text = Batale::Text.new(batale_text_params)

    if @batale_text.save
      redirect_to @batale_text, notice: t('success.create', model: Batale::Text.model_name.human)
    else
      render :new
    end
  end

  def update
    if @batale_text.update(batale_text_params)
      redirect_to @batale_text, notice: t('success.update', model: Batale::Text.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @batale_text.destroy
    redirect_to batale_texts_url, notice: t('success.destroy', model: Batale::Text.model_name.human)
  end

  private

  def next_and_previous_texts
    search_params = ActionController::Parameters.new(session[:search_params])
    batale_texts = Batale::Text.search(search_params)
    index = batale_texts.find_index(@batale_text)
    if index.present?
      @next = Batale::Text.find(batale_texts[index + 1].id) if batale_texts[index + 1].present?
      @previous = Batale::Text.find(batale_texts[index - 1].id) if index - 1 >= 0
    end
  end

  def set_batale_text
    authorize @batale_text = Batale::Text.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb 'Início', dashboard_index_path
    add_breadcrumb Batale::Text.model_name.human.pluralize, batale_texts_path
    case action_name
    when 'show'
      add_breadcrumb "Estrato #{@batale_text.stratum_number}", batale_texts_path + "?stratum_number=#{@batale_text.stratum_number}"
      add_breadcrumb @batale_text.code.to_s
    when 'edit'
      add_breadcrumb @batale_text.code.to_s, batale_text_path(@batale_text)
      add_breadcrumb 'Editando'
    end
  end

  def batale_text_params
    params
      .require(:batale_text)
      .permit(:code, :student_name, :student_number, :student_age, :student_sex, :stratum_number,
        :collection_number, :student_text_number, :collection_year, :type, :student_school,
        :student_grade, :student_class, :original, :normalized, :writing_type)
  end
end
