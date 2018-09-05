class Btp::AnalysesController < ApplicationController
  before_action :set_analysis, only: %i[show edit update destroy]
  before_action :set_breadcrumb, only: %i[index show]

  def index
    @analyses = Analysis.all
  end

  def show
    case @analysis.type_analyzed
    when 'Btp::Text' then analyze_texts(Btp::Text.find(@analysis.ids_analyzed))
    when 'Btp::Color' then analyze_colors(Btp::Color.find(@analysis.ids_analyzed))
    when 'Btp::Bloc' then analyze_blocs(Btp::Bloc.find(@analysis.ids_analyzed))
    end
  end

  def new
    @analysis = Analysis.new
  end

  def edit; end

  def create
    create_analysis_from_model

    if @analysis.save!
      redirect_to btp_analysis_path @analysis, notice: t('success.create', model: Analysis.model_name.human)
    else
      redirect_to(btp_texts_path)
    end
  end

  def update
    render partial: 'update', notice: t('sucess.update', model: Analysis.model_name.human) if @analysis.update!(analysis_params)
  end

  def destroy
    @analysis.destroy
    redirect_to btp_analyses_url, notice: t('success.destroy', model: Analysis.model_name.human)
  end

  private

  def add_breadcrumb_for_analyzed_type
    case @analysis.type_analyzed
    when 'Btp::Text' then add_breadcrumb Btp::Text.model_name.human.pluralize, btp_texts_path
    when 'Btp::Color' then add_breadcrumb Btp::Color.model_name.human.pluralize, btp_colors_path
    when 'Btp:Bloc' then add_breadcrumb Btp::Bloc.model_name.human.pluralize, btp_blocs_path
    end
    add_breadcrumb Analysis.model_name.human.pluralize, btp_analysis_path(@analysis)
  end

  def analysis_params
    # params.require(:analysis).permit(:label, :favorite, :type_analyzed, :ids_analyzed, :params_queried, :shared_with)
    params.require(:id)
    params.permit(:label, :favorite)
  end

  def analyze_blocs(blocs)
    excerpts = blocs.pluck(:excerpts)
    @info = {}

    @info['blocs_count'] = blocs.count
    @info.merge!(analyze_excerpts(excerpts))
    @info
  end

  def analyze_colors(colors)
    excerpts = colors.pluck(:excerpts)
    @info = {}

    @info['colors_count'] = colors.count
    @info.merge!(analyze_excerpts(excerpts))
    @info
  end

  def analyze_excerpts(excerpts)
    texts = Btp::Text.find(excerpts.pluck(:text_id).uniq)
    info = {}

    info['acronym'] = WordsCounted.count(texts.pluck(:acronym).join(' '))
    info['class_number'] = WordsCounted.count(texts.pluck(:class_number).join(' '))
    info['excerpts_count'] = excerpts.count
    info['region'] = WordsCounted.count(texts.pluck(:region).join(' '))
    info['texts_count'] = texts.count
    info['words_count'] = WordsCounted.count(excerpts.map(&:excerpt).join(' '), exclude: Analysis.stop_words)
    info['year'] = WordsCounted.count(texts.pluck(:year).join(' '))
    info
  end

  def analyze_texts(texts)
    @info = {}
    texts_grouped_by_acronym = texts.group_by(&:acronym)
    texts_grouped_by_class_number = texts.group_by(&:class_number)
    texts_grouped_by_region = texts.group_by(&:region)
    texts_grouped_by_teacher_number = texts.group_by(&:teacher_number)
    texts_grouped_by_year = texts.group_by(&:year)
    full_texts_plucked = texts.pluck(:full)

    @info['texts_count'] = texts.count
    @info['class_number_pluck'] = texts.pluck(:class_number).uniq
    @info['year_pluck'] = texts.pluck(:year).uniq.map(&:to_i)
    @info['region_pluck'] = texts.pluck(:region).uniq
    @info['acronym_pluck'] = texts.pluck(:acronym).uniq
    @info['text_count_by_acronym'] = texts_grouped_by_acronym.map { |group| [group[0], group[1].count] }
    @info['text_count_by_class_number'] = texts_grouped_by_class_number.map { |group| [group[0], group[1].count] }
    @info['text_count_by_region'] = texts_grouped_by_region.map { |group| [group[0], group[1].count] }
    @info['text_count_by_teacher_number'] = texts_grouped_by_teacher_number.map { |group| [group[0], group[1].count] }
    @info['text_count_by_year'] = texts_grouped_by_year.map { |group| [group[0], group[1].count] }
    @info['words_count'] = WordsCounted.count(full_texts_plucked.join(' '), exclude: Analysis.stop_words)

    if @analysis.params_queried['full'].present?
      @info['word_occurrences_match'], @info['word_occurrences_strict'] =
        count_occurrences_of_queried_params @analysis.params_queried['full']
    end
    # texts
    # @info['text_info_by_year_and_class_number'] = {}
    # texts_grouped_by_year.each do |year, texts|
    #   @info['text_info_by_year_and_class_number'][year] = texts.group_by(&:class_number).map do |class_number, texts|
    #     {
    #       class_number => texts.count,
    #       'words' => WordsCounted.count(texts.map(&:full).join(' '), exclude: Analysis.stop_words)
    #     }
    #   end
    # end
    @info['words_counted_by_class_number'] =
      texts_grouped_by_class_number
      .map { |cn, t| [cn, WordsCounted.count(t.map(&:full).join(' '), exclude: Analysis.stop_words)] }
      .sort_by { |cn, _texts| cn.to_i }
  end

  def count_occurrences_of_queried_params(params)
    w_match = {}
    w_strict = {}
    Array(params).each do |term|
      next if Analysis.stop_words.include?(term)
      w_match[term] = count_occurrences term, @info['words_count'], 'match'
      w_strict[term] = count_occurrences term, @info['words_count'], 'strict'
    end
    [w_match, w_strict]
  end

  def count_occurrences(term, text_counted, method)
    if method == 'match'
      return text_counted.token_frequency
                         .map { |item| item[1] if /#{term}/i.match?(item[0]) }
                         .compact.reduce(:+)
    end
    if method == 'strict'
      return text_counted.token_frequency
                         .map { |item| item[1] if item[0] == term }
                         .compact.reduce(:+)
    end
  end

  def create_analysis_from_model
    came_from = session[:search_params]['controller'].split('/')
    if came_from.include?('texts')
      @analysis = Analysis.from_btp_texts(current_user.id, session[:search_params])
    elsif came_from.include?('colors')
      @analysis = Analysis.from_colors(current_user.id, session[:search_params])
    elsif came_from.include?('blocs')
      @analysis = Analysis.from_blocs(current_user.id, session[:search_params])
    else
      raise 'Não foi possível criar uma análise'
    end
  end

  def set_analysis
    @analysis = Analysis.find(params[:id])
  end

  def set_breadcrumb
    add_breadcrumb 'Início', dashboard_index_path
    if @analysis.present?
      add_breadcrumb_for_analyzed_type
    else
      add_breadcrumb Analysis.model_name.human.pluralize, btp_analyses_path
    end
  end
end
