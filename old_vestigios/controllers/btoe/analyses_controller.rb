class Btoe::AnalysesController < ApplicationController
  def index
    add_breadcrumb 'Início', dashboard_path
    puts session[:search_params]
    p request.referrer
    if !request.referrer.nil?
      came_from = request.referrer.split('/')
      p came_from
      if came_from.last.include?('see_more') || came_from.include?('texts')
        add_breadcrumb 'Textos', btoe_texts_path
        add_breadcrumb 'Análises', btoe_analyses_path
        p 'texts ou see_more'
        @textos = Btoe::Text.search(session[:search_params])

        total = ''
        sigla_total = ''
        ano_total = ''
        polo_total = ''
        turmas_total = {}
        @textos.each do |texto|
          total += texto.texto_full + "\n"
          sigla_total += texto.sigla + "\n"
          ano_total += texto.ano.to_s + "\n"
          polo_total += texto.polo + "\n"
        end
        @counter = WordsCounted.count(total, exclude: get_stop_words)
        @siglas_count = WordsCounted.count(sigla_total)
        @polos_count = WordsCounted.count(polo_total)
        @anos_count = WordsCounted.count(ano_total, pattern: /[\p{Alnum}\-']+/)
        @anos_count.token_frequency.each do |ano|
          @textos.where(ano: ano[0].to_i).each do |texto|
            !turmas_total[ano[0].to_i].nil? ? (turmas_total[ano[0].to_i] += texto.turma.to_s + "\n") : (turmas_total[ano[0].to_i] = texto.turma.to_s + "\n")
          end
        end
        @turmas_count = {}
        turmas_total.each_pair do |k, _v|
          @turmas_count[k] = WordsCounted.count(turmas_total[k], pattern: /[\p{Alnum}\-']+/)
        end

        unless session[:search_params]['content'].nil?
          @content = {}
          procurado = session[:search_params]['content'].split(';')
          procurado.each do |termo|
            termo.split.each do |palavra|
              next if get_stop_words.include?(palavra)
              @counter.token_frequency.each do |slice|
                @content[palavra] = slice[1] if palavra == slice[0]
              end
            end
          end

        end

        # byebug
      elsif came_from.include?('colors')
        add_breadcrumb 'Cores', btoe_colors_path
        add_breadcrumb 'Análises', btoe_analyses_path
        p 'colors'
        @colors = Btoe::Color.search(session[:search_params])
      elsif came_from.include?('blocs')
        add_breadcrumb 'Blocos', btoe_blocs_path
        add_breadcrumb 'Análises', btoe_analyses_path
        p 'blocs'
        @blocs = Btoe::Blocs.search(session[:search_params])
      else
        p 'masoq'
      end
    else
      p 'Referrer é nil'
      # redirect_to root_path
    end
  end
end
