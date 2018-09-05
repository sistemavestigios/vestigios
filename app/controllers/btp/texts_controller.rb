class Btp::TextsController < ApplicationController
  before_action :set_btp_text, only: %i[show edit update destroy]
  before_action :set_breadcrumbs

  def index
    authorize @btp_texts = Btp::Text.search(params)
    session[:search_params] = request.params
    @btp_texts = @btp_texts.page(params[:page] || 1).per(params[:per_page] || 5)
    @thematics = Btp::Text.thematics
    session[:search_params] = request.query_parameters
  end

  def show
    next_and_previous_texts
    @btp_blocs = Btp::Bloc.all
    @btp_colors = Btp::Color.all
    @associated_blocs = Btp::Bloc.in(text_ids: @btp_text.id)
    @associated_colors = Btp::Color.in(text_ids: @btp_text.id)
  end

  def new
    authorize @btp_text = Btp::Text.new
  end

  def edit; end

  def create
    authorize @btp_text = Btp::Text.new(btp_text_params)

    if @btp_text.save
      redirect_to @btp_text, notice: t('success.create', model: Btp::Text.model_name.human)
    else
      render :new
    end
  end

  def update
    if @btp_text.update(btp_text_params)
      redirect_to @btp_text, notice: t('success.update', model: Btp::Text.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @btp_text.destroy
    redirect_to btp_texts_url, notice: t('success.destroy', model: Btp::Text.model_name.human)
  end

  private

  def next_and_previous_texts
    search_params = ActionController::Parameters.new(session[:search_params])
    btp_texts = Btp::Text.search(search_params)
    index = btp_texts.find_index(@btp_text)
    if index.present?
      @next = Btp::Text.find(btp_texts[index + 1].id) if btp_texts[index + 1].present?
      @previous = Btp::Text.find(btp_texts[index - 1].id) if index - 1 >= 0
    end
  end

  def set_breadcrumbs
    add_breadcrumb 'Início', dashboard_index_path
    add_breadcrumb Btp::Text.model_name.human.pluralize, btp_texts_path
    case action_name
    when 'show'
      add_breadcrumb "Temática #{@btp_text.acronym}", btp_texts_path + "?acronym=#{@btp_text.acronym}"
      add_breadcrumb @btp_text.code.to_s
    when 'edit'
      add_breadcrumb @btp_text.code.to_s, btp_text_path(@btp_text)
      add_breadcrumb 'Editando'
    end
  end

  def set_btp_text
    authorize @btp_text = Btp::Text.find(params[:id])
  end

  def btp_text_params
    params
      .require(:btp_text)
      .permit(:year, :code, :teacher_number, :region, :full, :class_number, :acronym)
  end
end
