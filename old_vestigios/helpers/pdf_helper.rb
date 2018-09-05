# frozen_string_literal: true

module PdfHelper
  ROBOTO_REGULAR = 'vendor/fonts/Roboto-Regular.ttf'
  ROBOTO_BOLD = 'vendor/fonts/Roboto-Bold.ttf'
  TABLE_COL_NAMES = {
    'texto_id' =>            'Cód. Texto',
    'palavra_marcada' =>     'Erro',
    'palavra_correta' =>     'Alvo',
    'serie' =>               'Série/Ano',
    'numero_coleta' =>       'Coleta',
    'sexo' =>                'Sexo',
    'estrato' =>             'Estrato',
    'idade' =>               'Idade',
    'ano_coleta' =>          'Ano Coleta',
    'tipo_texto' =>          'T. Texto',
    'numero_texto' =>        'Nr. Texto',
    'numero_aluno' =>        'Aluno',
    'escola_crianca' =>      'Escola'
  }.freeze
  BLACK = '000000'

  class HighlightCallback
    def initialize(options)
      @color = options[:color]
      @document = options[:document]
    end

    def render_behind(fragment)
      original_color = @document.fill_color
      @document.fill_color = @color
      @document.fill_rectangle(
        fragment.top_left,
        fragment.width,
        fragment.height
      )
      @document.fill_color = original_color
    end
  end

  def pdf(obj, params = {})
    if obj.class == Batale::Definition
      pdf_batale_definition(obj, params)
    elsif obj.class == Array
      if obj[0].class == Batale::Definition
        pdf_batale_definitions(obj, params)
      elsif obj[0].class == Btoe::Color
        pdf_btoe_colors(obj, params)
      elsif obj[0].class == Btoe::Bloc
        pdf_btoe_blocs(obj, params)
      end
    elsif obj.class == Mongoid::Criteria
      if obj.klass == Batale::Text
        pdf_batale_tns(obj, params)
      elsif obj.klass == Btoe::Text
        pdf_btoe_texts(obj, params)
      elsif obj.klass == Btoe::Color
        pdf_btoe_colors(obj, params)
      elsif obj.klass == Btoe::Bloc
        pdf_btoe_blocs(obj, params)
      end
    elsif obj.class == Btoe::Bloc
      pdf_btoe_bloc(obj, params)
    elsif obj.class == Btoe::Text
      pdf_btoe_text(obj, params)
    elsif obj.class == Btoe::Color
      pdf_btoe_color(obj, params)
    end
  end

  private

  def pdf_batale_definition(batale_definition, params)
    pdf = Prawn::Document.new(margin: [10, 0, 0, 10])
    # :margin:        Sets the margin on all sides in points [0.5 inch]
    # :left_margin:   Sets the left margin in points [0.5 inch]
    # :right_margin:  Sets the right margin in points [0.5 inch]
    # :top_margin:    Sets the top margin in points [0.5 inch]
    # :bottom_margin: Sets the bottom margin in points [0.5 inch]

    # Cria o cabeçalho do pdf
    pdf.font(ROBOTO_REGULAR)
    pdf.text "Regra: #{batale_definition.regra}\n", size: 14, color: '0000FF'
    pdf.text "Exemplo: #{batale_definition.exemplo}\n"
    pdf.text "Palavra alvo: #{batale_definition.palavra_alvo}\n"
    pdf.text "Categoria: #{batale_definition.errortog_name}\n"
    pdf.text 'Contagem: ' + pluralize(batale_definition.texts.count, 'texto associado', 'textos associados') +
             ' a essa regra.', size: 12
    pdf.text 'Contagem: ' + pluralize(batale_definition.words.count, 'palavra errada associada', 'palavras erradas associadas') +
             ' a essa regra.', size: 12
    pdf.text "\n"

    table_data = [[]]
    colors = %w[F0F0F0 FFFFCC]
    # Gera as colunas
    params.keys.each { |key| table_data[0] += [TABLE_COL_NAMES[key]] }

    # Preenche as linhas
    batale_definition.words.each_with_index do |excerpt, i|
      text = Batale::Text.find(excerpt.text_id)
      row = i + 1
      table_data += [[]]
      col_fields = {
        'texto_id' =>            text.codigo_texto,
        'palavra_marcada' =>     excerpt.trecho,
        'palavra_correta' =>     excerpt.palavra_correta,
        'serie' =>               text.serie,
        'numero_coleta' =>       text.numero_coleta,
        'sexo' =>                text.sexo,
        'estrato' =>             text.numero_estrato,
        'idade' =>               text.idade,
        'ano_coleta' =>          text.ano_coleta,
        'tipo_texto' =>          text.tipo_texto,
        'numero_texto' =>        text.numero_texto,
        'numero_aluno' =>        text.numero_aluno,
        'escola_crianca' =>      text.escola_crianca
      }
      params.keys.each { |key| table_data[row] += [col_fields[key]] }
    end

    pdf.table(table_data, width: 592, row_colors: colors)
    pdf
  end

  def pdf_batale_definitions(def_ids, params)
    pdf = Prawn::Document.new(margin: [10, 0, 0, 10])
    # :margin:        Sets the margin on all sides in points [0.5 inch]
    # :left_margin:   Sets the left margin in points [0.5 inch]
    # :right_margin:  Sets the right margin in points [0.5 inch]
    # :top_margin:    Sets the top margin in points [0.5 inch]
    # :bottom_margin: Sets the bottom margin in points [0.5 inch]
    pdf.font(ROBOTO_REGULAR)

    def_ids.each do |id|
      batale_definition = Batale::Definition.find(id)
      # Cria o cabeçalho do pdf
      pdf.text "Regra: #{batale_definition.regra}\n", size: 14, color: '0000FF'
      pdf.text "Exemplo: #{batale_definition.exemplo}\n"
      pdf.text "Palavra alvo: #{batale_definition.palavra_alvo}\n"
      pdf.text "Categoria: #{batale_definition.errortog_name}\n"
      pdf.text 'Contagem: ' + pluralize(batale_definition.texts.count, 'texto associado', 'textos associados') +
               ' a essa regra.', size: 12
      pdf.text 'Contagem: ' + pluralize(batale_definition.words.count, 'palavra errada associada', 'palavras erradas associadas') +
               ' a essa regra.', size: 12
      pdf.text "\n"

      table_data = [[]]
      colors = %w[F0F0F0 FFFFCC]
      # Gera as colunas
      params.keys.each { |key| table_data[0] += [TABLE_COL_NAMES[key]] }

      # Preenche as linhas
      batale_definition.words.each_with_index do |excerpt, i|
        text = Batale::Text.find(excerpt.text_id)
        row = i + 1
        table_data += [[]]
        col_fields = {
          'texto_id' =>            text.codigo_texto,
          'palavra_marcada' =>     excerpt.trecho,
          'palavra_correta' =>     excerpt.palavra_correta,
          'serie' =>               text.serie,
          'numero_coleta' =>       text.numero_coleta,
          'sexo' =>                text.sexo,
          'estrato' =>             text.numero_estrato,
          'idade' =>               text.idade,
          'ano_coleta' =>          text.ano_coleta,
          'tipo_texto' =>          text.tipo_texto,
          'numero_texto' =>        text.numero_texto,
          'numero_aluno' =>        text.numero_aluno,
          'escola_crianca' =>      text.escola_crianca
        }
        params.keys.each { |key| table_data[row] += [col_fields[key]] }
      end
      pdf.table(table_data, width: 592, row_colors: colors)
      pdf.move_down 15
    end
    pdf
  end

  def pdf_batale_tns(criteria, params)
    pdf = Prawn::Document.new
    pdf.font(ROBOTO_BOLD)
    if params[:show_header] == 'true'
      pdf.text "Coleção de textos gerada a partir dos campos:\n", size: 14, color: '0000FF'
      pdf.font(ROBOTO_REGULAR)
      pdf.text "Busca por conteúdo: #{params[:search_content]}\n", size: 14, color: BLACK unless params[:search_content].empty?
      pdf.text "Idade: #{params[:age]}\n", size: 14, color: BLACK unless params[:age].empty?
      pdf.text "Sexo: #{params[:gender]}\n", size: 14, color: BLACK unless params[:gender].empty?
      pdf.text "Número do aluno: #{params[:number_student]}\n", size: 14, color: BLACK unless params[:number_student].empty?
      pdf.text "Escola: #{params[:school]}\n", size: 14, color: BLACK unless params[:school].empty?
      pdf.text "Turma: #{params[:class]}\n", size: 14, color: BLACK unless params[:class].empty?
      pdf.text "Número Estrato: #{params[:stratum]}\n", size: 14, color: BLACK unless params[:stratum].empty?
      pdf.text "Número Coleta: #{params[:collection]}\n", size: 14, color: BLACK unless params[:collection].empty?
      pdf.text "Número do Texto: #{params[:number_text]}\n", size: 14, color: BLACK unless params[:number_text].empty?
      pdf.text "Ano da Coleta: #{params[:year]}\n", size: 14, color: BLACK unless params[:year].empty?
      pdf.text "Tipo do Texto: #{params[:type]}\n", size: 14, color: BLACK unless params[:type].empty?
    end
    criteria.all.each do |batale_text|
      pdf.font(ROBOTO_BOLD)
      pdf.text "\nCódigo do texto: #{batale_text.codigo_texto}\n", size: 14, color: BLACK if params[:show_codigo_texto] == 'true'
      pdf.text "\nTexto Original:", size: 14, color: BLACK if params[:show_texto_original] == 'true' && params[:show_text_label] == 'true'
      pdf.font(ROBOTO_REGULAR)
      pdf.text "\n#{batale_text.texto_original}", size: 14, color: BLACK if params[:show_texto_original] == 'true'
      pdf.font(ROBOTO_BOLD)
      pdf.text "\nTexto Normatizado:", size: 14, color: BLACK if params[:show_texto_normatizado] == 'true' && params[:show_text_label] == 'true'
      pdf.font(ROBOTO_REGULAR)
      pdf.text "\n#{batale_text.texto_normatizado}", size: 14, color: BLACK if params[:show_texto_normatizado] == 'true'
    end
    pdf
  end

  def pdf_btoe_texts(criteria, params)
    pdf = Prawn::Document.new(margin: [10, 0, 0, 10])
    if params[:show_header] == 'true'
      pdf.font(ROBOTO_BOLD)
      pdf.text "Coleção de textos gerada a partir dos campos:\n", size: 14, color: '0000FF'
      pdf.font(ROBOTO_REGULAR)
      pdf.text "Busca por conteúdo: #{params[:content]}\n", size: 14, color: BLACK unless params[:content].empty?
      pdf.text "Sigla: #{params[:sigla]}\n", size: 14, color: BLACK unless params[:sigla].empty?
      pdf.text "Ano: #{params[:ano]}\n", size: 14, color: BLACK unless params[:ano].empty?
      pdf.text "Polo: #{params[:polo]}\n", size: 14, color: BLACK unless params[:polo].empty?
      pdf.text "Turma: #{params[:turma]}\n", size: 14, color: BLACK unless params[:turma].empty?
      pdf.text "Número da Professora: #{params[:numero_professora]}\n", size: 14, color: BLACK unless params[:numero_professora].empty?
    end
    criteria.all.each do |btoe_text|
      pdf.font(ROBOTO_BOLD)
      pdf.text "\nCódigo do texto: #{btoe_text.codigo_texto}\n", size: 14, color: BLACK if params[:show_codigo_texto] == 'true'
      pdf.text "\nTexto Original:", size: 14, color: BLACK if params[:show_texto_original] == 'true'
      pdf.font(ROBOTO_REGULAR)
      pdf.text "\n#{btoe_text.texto_full}", size: 14, color: BLACK if params[:show_texto_original] == 'true'
      pdf.font(ROBOTO_BOLD)
    end
    pdf
  end

  def pdf_btoe_bloc(btoe_bloc, params)
    pdf = Prawn::Document.new(margin: [10, 0, 0, 10])
    pdf.font(ROBOTO_REGULAR)
    pdf.text "Nome do bloco: #{btoe_bloc.nome}\n", size: 14, color: '0000FF'
    pdf.text "Descrição do bloco: #{btoe_bloc.descricao}\n"
    pdf.text "\n"
    if btoe_bloc.excerpts?
      pdf.font(ROBOTO_BOLD)
      pdf.text 'Trechos:', size: 14, color: BLACK
      btoe_bloc.excerpts.each do |excerpt|
        pdf.font(ROBOTO_BOLD)
        pdf.text "Trecho vindo de: #{excerpt.get_codigo_texto}", size: 14, color: BLACK
        pdf.font(ROBOTO_REGULAR)
        pdf.text (Prawn::Text::NBSP * 4 + excerpt.trecho).to_s, size: 14, color: BLACK
        next unless excerpt.comments? && params[:show_excerpt_comments] == 'true'
        excerpt.comments.each do |comment|
          pdf.font(ROBOTO_BOLD)
          pdf.text (Prawn::Text::NBSP * 4 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
          pdf.font(ROBOTO_REGULAR)
          pdf.text (Prawn::Text::NBSP * 8 + comment.comment).to_s, size: 14, color: BLACK
        end
      end
    end
    if btoe_bloc.comments? && params[:show_bloc_comments] == 'true'
      pdf.font(ROBOTO_BOLD)
      pdf.text 'Comentários do bloco:', size: 14, color: BLACK
      btoe_bloc.comments.each do |comment|
        pdf.text (Prawn::Text::NBSP * 4 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
        pdf.font(ROBOTO_REGULAR)
        pdf.text (Prawn::Text::NBSP * 8 + comment.comment).to_s, size: 14, color: BLACK
        next unless params[:show_comment_comments] && params[:show_comment_comments] == 'true'
        pdf.font(ROBOTO_BOLD)
        pdf.text (Prawn::Text::NBSP * 4 + 'Comentários de comentário:').to_s, size: 14, color: BLACK
        comment.child_comments.each do |comment|
          pdf.font(ROBOTO_BOLD)
          pdf.text (Prawn::Text::NBSP * 8 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
          pdf.font(ROBOTO_REGULAR)
          pdf.text (Prawn::Text::NBSP * 12 + comment.comment).to_s, size: 14, color: BLACK
        end
      end
    end
    pdf
  end

  def pdf_btoe_blocs(btoe_blocs, params)
    pdf = Prawn::Document.new(margin: [10, 0, 0, 10])
    btoe_blocs.each do |btoe_bloc|
      pdf.font(ROBOTO_REGULAR)
      pdf.text "Nome do bloco: #{btoe_bloc.nome}\n", size: 14, color: '0000FF'
      pdf.text "Descrição do bloco: #{btoe_bloc.descricao}\n"
      pdf.text "\n"
      if btoe_bloc.excerpts?
        pdf.font(ROBOTO_BOLD)
        pdf.text 'Trechos:', size: 14, color: BLACK
        btoe_bloc.filtered_excerpts(params).each do |excerpt|
          pdf.font(ROBOTO_BOLD)
          pdf.text "Trecho vindo de: #{excerpt.get_codigo_texto}", size: 14, color: BLACK
          pdf.font(ROBOTO_REGULAR)
          pdf.text (Prawn::Text::NBSP * 4 + excerpt.trecho).to_s, size: 14, color: BLACK
          next unless excerpt.comments? && params[:show_excerpt_comments] == 'true'
          excerpt.comments.each do |comment|
            pdf.font(ROBOTO_BOLD)
            pdf.text (Prawn::Text::NBSP * 4 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
            pdf.font(ROBOTO_REGULAR)
            pdf.text (Prawn::Text::NBSP * 8 + comment.comment).to_s, size: 14, color: BLACK
          end
        end
      end
      if btoe_bloc.comments? && params[:show_bloc_comments] == 'true'
        pdf.font(ROBOTO_BOLD)
        pdf.text 'Comentários do bloco:', size: 14, color: BLACK
        btoe_bloc.comments.each do |comment|
          pdf.text (Prawn::Text::NBSP * 4 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
          pdf.font(ROBOTO_REGULAR)
          pdf.text (Prawn::Text::NBSP * 8 + comment.comment).to_s, size: 14, color: BLACK
          next unless params[:show_comment_comments] && params[:show_comment_comments] == 'true'
          pdf.font(ROBOTO_BOLD)
          pdf.text (Prawn::Text::NBSP * 4 + 'Comentários de comentário:').to_s, size: 14, color: BLACK
          comment.child_comments.each do |comment|
            pdf.font(ROBOTO_BOLD)
            pdf.text (Prawn::Text::NBSP * 8 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
            pdf.font(ROBOTO_REGULAR)
            pdf.text (Prawn::Text::NBSP * 12 + comment.comment).to_s, size: 14, color: BLACK
          end
        end
      end
      pdf.text "\n"
    end
    pdf
  end

  def pdf_btoe_text(btoe_text, params)
    color_excerpt = { color: [], excerpt: [] }
    associated = if params[:show_associations_of].nil?
                   btoe_text.find_associated_colors_and_excerpts[:all]
                 else
                   btoe_text.find_associated_colors_and_excerpts(params[:show_associations_of])[:user]
                 end
    text = btoe_text.texto_full
    index = {}
    trechos = []
    cores = []
    legenda = {}
    associated.each do |h|
      h.each do |k, v|
        k == :color ? (color_excerpt[k] << v.hex_color.delete('#'); legenda[v.tag] = v.hex_color.delete('#')) : color_excerpt[k] << v.trecho
      end
    end
    color_excerpt[:excerpt].each_with_index { |e, i| index[text.index(e)] = i }
    until index.empty?
      menor = text.size
      index.each { |k, _v| menor = k if k < menor }
      trechos << color_excerpt[:excerpt][index[menor]]
      cores << color_excerpt[:color][index[menor]]
      index.delete(menor)
    end

    Dir.mkdir('public/btoe') if Dir.glob('public/btoe') == []
    Dir.mkdir('public/btoe/text') if Dir.glob('public/btoe/text') == []

    Prawn::Document.generate("public/btoe/text/#{btoe_text.codigo_texto.tr('/', '-')}.pdf") do
      font ROBOTO_REGULAR
      a_trechos = []
      trechos.each_with_index do |trecho, i|
        antes, igual, text = text.partition(trecho)
        highlight = HighlightCallback.new(color: cores[i], document: self)
        a_trechos << { text: antes } << { text: igual, callback: highlight }
      end
      a_trechos << { text: text }
      formatted_text a_trechos
      move_down 15
      text 'Legenda:'
      legenda.each do |tag, color|
        highlight = HighlightCallback.new(color: color, document: self)
        fill_color color
        fill_rectangle [5, cursor - 2], 15, 15
        fill_color '000000'
        draw_text tag, at: [25, cursor - 15]
        text "\n"
      end
    end
  end

  def pdf_btoe_color(btoe_color, params)
    pdf = Prawn::Document.new(margin: [10, 0, 0, 10])
    pdf.font(ROBOTO_REGULAR)
    color = btoe_color.hex_color[1, btoe_color.hex_color.size - 1]
    pdf.text "Cor criada por: #{btoe_color.user.full_name}\n", size: 14, color: '0000FF'
    pdf.text "Legenda da cor: #{btoe_color.tag}", size: 14, color: BLACK
    pdf.text 'Cor:', size: 14, color: BLACK
    pdf.fill_color color
    pdf.fill_rectangle [28, pdf.cursor + 16], 15, 15
    if btoe_color.excerpts?
      pdf.font(ROBOTO_BOLD)
      pdf.text 'Trechos:', size: 14, color: BLACK
      btoe_color.excerpts.each do |excerpt|
        pdf.font(ROBOTO_BOLD)
        pdf.text "Trecho vindo de: #{excerpt.get_codigo_texto}", size: 14, color: BLACK
        pdf.font(ROBOTO_REGULAR)
        pdf.text (Prawn::Text::NBSP * 4 + excerpt.trecho).to_s, size: 14, color: BLACK
        next unless excerpt.comments? && params[:show_excerpt_comments] == 'true'
        excerpt.comments.each do |comment|
          pdf.font(ROBOTO_BOLD)
          pdf.text (Prawn::Text::NBSP * 4 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
          pdf.font(ROBOTO_REGULAR)
          pdf.text (Prawn::Text::NBSP * 8 + comment.comment).to_s, size: 14, color: BLACK
        end
      end
    end
    if btoe_color.comments? && params[:show_color_comments] == 'true'
      pdf.font(ROBOTO_BOLD)
      pdf.text 'Comentários da cor:', size: 14, color: BLACK
      btoe_color.comments.each do |comment|
        pdf.text (Prawn::Text::NBSP * 4 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
        pdf.font(ROBOTO_REGULAR)
        pdf.text (Prawn::Text::NBSP * 8 + comment.comment).to_s, size: 14, color: BLACK
        next unless params[:show_comment_comments] && params[:show_comment_comments] == 'true'
        pdf.font(ROBOTO_BOLD)
        pdf.text (Prawn::Text::NBSP * 4 + 'Comentários de comentário:').to_s, size: 14, color: BLACK
        comment.child_comments.each do |comment|
          pdf.font(ROBOTO_BOLD)
          pdf.text (Prawn::Text::NBSP * 8 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
          pdf.font(ROBOTO_REGULAR)
          pdf.text (Prawn::Text::NBSP * 12 + comment.comment).to_s, size: 14, color: BLACK
        end
      end
    end
    pdf
  end

  def pdf_btoe_colors(btoe_colors, params)
    pdf = Prawn::Document.new(margin: [10, 0, 0, 10])
    btoe_colors.each do |btoe_color|
      pdf.font(ROBOTO_REGULAR)
      color = btoe_color.hex_color[1, btoe_color.hex_color.size - 1]
      pdf.text "Cor criada por: #{btoe_color.user.full_name}\n", size: 14, color: '0000FF'
      pdf.text "Legenda da cor: #{btoe_color.tag}", size: 14, color: BLACK
      pdf.text 'Cor:', size: 14, color: BLACK
      pdf.fill_color color
      pdf.fill_rectangle [28, pdf.cursor + 16], 15, 15
      if btoe_color.excerpts?
        pdf.font(ROBOTO_BOLD)
        pdf.text 'Trechos:', size: 14, color: BLACK
        btoe_color.filtered_excerpts(params).each do |excerpt|
          pdf.font(ROBOTO_BOLD)
          pdf.text "Trecho vindo de: #{excerpt.get_codigo_texto}", size: 14, color: BLACK
          pdf.font(ROBOTO_REGULAR)
          pdf.text (Prawn::Text::NBSP * 4 + excerpt.trecho).to_s, size: 14, color: BLACK
          next unless excerpt.comments? && params[:show_excerpt_comments] == 'true'
          excerpt.comments.each do |comment|
            pdf.font(ROBOTO_BOLD)
            pdf.text (Prawn::Text::NBSP * 4 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
            pdf.font(ROBOTO_REGULAR)
            pdf.text (Prawn::Text::NBSP * 8 + comment.comment).to_s, size: 14, color: BLACK
          end
        end
      end
      if btoe_color.comments? && params[:show_color_comments] == 'true'
        pdf.font(ROBOTO_BOLD)
        pdf.text 'Comentários da cor:', size: 14, color: BLACK
        btoe_color.comments.each do |comment|
          pdf.text (Prawn::Text::NBSP * 4 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
          pdf.font(ROBOTO_REGULAR)
          pdf.text (Prawn::Text::NBSP * 8 + comment.comment).to_s, size: 14, color: BLACK
          next unless params[:show_comment_comments] && params[:show_comment_comments] == 'true'
          pdf.font(ROBOTO_BOLD)
          pdf.text (Prawn::Text::NBSP * 4 + 'Comentários de comentário:').to_s, size: 14, color: BLACK
          comment.child_comments.each do |comment|
            pdf.font(ROBOTO_BOLD)
            pdf.text (Prawn::Text::NBSP * 8 + 'Comentário de: ' + comment.user.full_name).to_s, size: 14, color: BLACK
            pdf.font(ROBOTO_REGULAR)
            pdf.text (Prawn::Text::NBSP * 12 + comment.comment).to_s, size: 14, color: BLACK
          end
        end
      end
      pdf.text "\n"
    end
    pdf
  end
end
