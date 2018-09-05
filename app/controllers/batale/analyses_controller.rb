class Batale::AnalysesController < ApplicationController
  before_action :set_analysis, only: %i[show edit update destroy]
  before_action :set_breadcrumb, only: [:show]

  def index
    @analyses = Analysis.all
  end

  def show
    analyze_texts(Batale::Text.find(@analysis.ids_analyzed))
  end

  def new
    @analysis = Analysis.new
  end

  def edit; end

  def create
    create_analysis_from_model
    if @analysis.save!
      redirect_to batale_analysis_path @analysis, notice: t('success.create', model: Analysis.model_name.human)
    else
      redirect_to batale_texts_path, notice: 'Something went wrong when creating your analysis'
    end
  end

  def update
    if @analysis.update!(analysis_params)
      # redirect_to batale_analysis_path @analysis, notice: 'Analysis was successfully updated.'
      render partial: 'update'
    else
      # render :edit
      redirect_to batale_analysis_path @analysis, notice: 'Something went wrong updating.'
    end
  end

  def destroy
    @analysis.destroy
    redirect_to batale_analyses_url, notice: 'Analysis was successfully destroyed.'
  end

  private

  def analysis_params
    # params.require.to_s(:analysis).permit(:label, :favorite, :type_analyzed, :ids_analyzed, .to_s:params_queried, :shared_with)
    params.require(:id)
    params.permit(:label, :favorite)
  end

  def analyze_texts(texts)
    collection_number = ''
    collection_year = ''
    normalized = ''
    student_age = ''
    student_number = ''
    student_sex = ''
    type = ''
    texts.each do |text|
      collection_number += remove_leading_zeros(text.collection_number) + ' '
      collection_year += text.collection_year.gsub(/\D/, '') + ' '
      normalized += text.normalized + ' ' unless text.normalized.nil?
      student_age += format_student_age(text.student_age) + ' '
      student_number += remove_leading_zeros(text.student_number) + ' '
      student_sex += text.student_sex + ' '
      type += text.type.gsub(/\D/, '') + ' '
    end

    @info = {}
    @info['collection_number'] = WordsCounted.count(collection_number, pattern: /[\p{Alnum}\-']+/)
    @info['collection_year'] = WordsCounted.count(collection_year, pattern: /[\p{Alnum}\-']+/)
    @info['normalized'] = WordsCounted.count(normalized, exclude: Analysis.stop_words)
    @info['student_age'] = WordsCounted.count(student_age, pattern: /[\p{Alnum}\-']+/)
    @info['student_number'] = WordsCounted.count(student_number, pattern: /[\p{Alnum}\-']+/)
    @info['student_sex'] = WordsCounted.count(student_sex, exclude: Analysis.stop_words)
    @info['texts_count'] = texts.count
    @info['type'] = WordsCounted.count(type, exclude: Analysis.stop_words)

    if @analysis.params_queried['normalized'].present?
      @info['word_occurrences_strict'], @info['word_occurrences_match'] =
        count_occurrences_of_queried_params(@analysis.params_queried['normalized'])
    end

    @info['texts_by_student_class_count'] = texts.group_by(&:student_class).map { |group| [group[0], group[1].count] }
    @info['texts_by_student_grade_count'] = texts.group_by(&:student_grade).map { |group| [group[0], group[1].count] }
    @info['texts_by_student_school_count'] = texts.group_by(&:student_school).map { |group| [group[0], group[1].count] }
    @info['texts_by_stratum_number_count'] = texts.group_by(&:stratum_number).map { |group| [group[0], group[1].count] }
    @info['most_used_words_by_class'] = {}
    texts.group_by(&:student_class)
         .map { |group| [group[0], group[1].map(&:normalized).compact.join(' ')] }
         .each do |student_class, joined_text|
           @info['most_used_words_by_class'][student_class] = WordsCounted.count(joined_text, exclude: Analysis.stop_words)
         end
    # texts.group_by(&:stratum_number)
    #      .map{ |group| [group[0], group[1].map(&:collection_number)]}

    # texts.map { |t| t.definitions.map(&:errortog).map(&:name).join(' ')  }
    # Batale::Text.all.map { |t| t.definitions.map(&:errortog).map(&:name).join(' ')  }
  end

  def count_occurrences_of_queried_params(params)
    w_match = {}
    w_strict = {}
    Array(params).each do |term|
      next if Analysis.stop_words.include?(term)
      w_match[term] = count_occurrences @info['normalized'], term, 'match'
      w_strict[term] = count_occurrences @info['normalized'], term, 'strict'
    end
    [w_match, w_strict]
  end

  def count_occurrences(normalized_text_counted, term, method)
    ntc =
      if method == 'match'
        normalized_text_counted.token_frequency.map { |item| item[1] if /#{term}/i.match?(item[0]) }
      elsif method == 'strict'
        normalized_text_counted.token_frequency.map { |item| item[1] if item[0] == term }
      end
    ntc.compact.reduce(:+)
  end

  def create_analysis_from_model
    came_from = session[:search_params]['controller'].split('/')
    if came_from.include?('texts')
      @analysis = Analysis.from_batale_texts(current_user.id, session[:search_params])
    else
      raise 'Não foi possível criar uma análise'
    end
  end

  # poorly
  def format_student_age(age)
    remove_leading_zeros(age[0..1].gsub(/\D/, ''))
  end

  def remove_leading_zeros(number)
    number.to_i.to_s
  end

  def set_analysis
    @analysis = Analysis.find(params[:id])
  end

  def set_breadcrumb
    add_breadcrumb 'Início', dashboard_index_path
    case @analysis.type_analyzed
    when 'Batale::Text'
      add_breadcrumb Batale::Text.model_name.human.pluralize, batale_texts_path
    end
    add_breadcrumb Analysis.model_name.human.pluralize, batale_analysis_path(@analysis)
  end
end
