class Btoe::ColorsController < ApplicationController
  before_action :set_btoe_color, only: %i[show edit update destroy]

  # GET /btoe/colors
  # GET /btoe/colors.json
  def index
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Cores', btoe_colors_path
    @@params = {}
    if params['button'].nil?
      @@all_colors = Btoe::Color.all
      @btoe_colors = authorize Btoe::Color.all.page(params[:page]).per(20)
    else
      @btoe_colors = Set.new
      search_term_content = params[:content].gsub ' ', '.*'
      query1 = Set.new
      @@params = request.query_parameters
      if params[:color_tag] != ''
        query1 = Set.new(authorize(Btoe::Color.search(params)))
      elsif search_term_content == '' && params[:ano] == '' &&
            params[:turma] == '' && params[:sigla] == '' &&
            params[:polo] == '' && params[:numero_professora] == '' &&
            params[:comment_search] == ''
        @btoe_colors = authorize Btoe::Color.all.page(params[:page]).per(5)
        return @btoe_colors
      end
      # "color_tag"=>"", "content"=>"", "turma"=>"", "ano"=>"", "comment_search"=>""
      all_colors = Btoe::Color.all
      all_colors_set = all_colors.to_set

      all_colors.each do |color|
        # busca por conteudo(trecho) dos excerpts
        query2 = Set.new
        if search_term_content != ''
          if search_term_content.include?(';')
            trechos = []
            search_term_content.split(';').each { |slice| trechos << /#{slice}/i }
            queried = []
            trechos.each do |trecho|
              color.excerpts.where(trecho: /#{trecho}/i).each do |exc|
                queried << exc
              end
            end

          else
            queried = color.excerpts.where(trecho: /#{search_term_content}/i) || []
          end

          queried.each do |q|
            # itera sobre os excerpts retornados
            query2 << q._parent # e adiciona os colors respectivos
          end
        else
          query2 = nil
        end

        query3 = Set.new
        if params[:ano] != ''
          if params[:ano].include?(';')
            anos = []
            params[:ano].split(';').each { |slice| anos << slice }

            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              anos.each do |ano|
                query3 << color if text.ano == ano.to_i
              end
            end
          else
            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              query3 << color if text.ano == params[:ano].to_i
            end
          end
        else
          query3 = nil
        end

        query4 = Set.new
        if params[:turma] != ''
          if params[:turma].include?(';')
            turmas = []
            params[:turma].split(';').each { |slice| turmas << slice }

            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              turmas.each do |turma|
                query4 << color if text.turma == turma.to_i
              end
            end
          else
            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              query4 << color if text.turma == params[:turma].to_i
            end
          end
        else
          query4 = nil
        end

        query6 = Set.new
        if params[:sigla] != ''
          if params[:sigla].include?(';')
            siglas = []
            params[:sigla].split(';').each { |slice| siglas << slice }

            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              siglas.each do |sigla|
                query6 << color if /#{sigla}/i.match?(text.sigla)
              end
            end
          else
            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              query6 << color if /#{params[:sigla]}/i.match?(text.sigla)
            end
          end
        else
          query6 = nil
        end

        query7 = Set.new
        if params[:polo] != ''
          if params[:polo].include?(';')
            polos = []
            params[:polo].split(';').each { |slice| polos << slice }

            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              polos.each do |polo|
                query7 << color if /#{polo}/i.match?(text.polo)
              end
            end
          else
            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              query7 << color if /#{params[:polo]}/i.match?(text.polo)
            end
          end
        else
          query7 = nil
        end

        query8 = Set.new
        if params[:numero_professora] != ''
          if params[:numero_professora].include?(';')
            numeros_professoras = []
            params[:numero_professora].split(';').each { |slice| numeros_professoras << slice }

            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              numeros_professoras.each do |numero_professora|
                query8 << color if text.numero_professora == numero_professora.to_i
              end
            end
          else
            color.excerpts.each do |excerpt|
              text = Btoe::Text.find(excerpt.text_id)
              query8 << color if text.numero_professora == params[:numero_professora].to_i
            end
          end
        else
          query8 = nil
        end

        query5 = Set.new
        if params[:comment_search] != ''
          if params[:comment_search].include?(';')
            comments = []
            params[:comment_search].split(';').each { |slice| comments << /#{slice}/i }

            comments.each do |comment_searched|
              # p comment_searched
              color.comments.each do |color_comment|
                query5 << color if color_comment.comment.match?(comment_searched)

                color_comment.child_comments.each do |color_comment_child|
                  query5 << color if color_comment_child.comment.match?(comment_searched)
                end
              end

              color.excerpts.each do |excerpt|
                excerpt.comments.each do |exc_comment|
                  query5 << color if exc_comment.comment.match?(comment_searched)
                end
              end
            end
          else
            color.comments.where(comment: /#{params[:comment_search]}/i).each do |_comment|
              query5 << color
            end
            color.comments.each do |comment|
              comment.child_comments.where(comment: /#{params[:comment_search]}/i).each do |_cc|
                query5 << color
              end
            end
            color.excerpts.each do |excerpt|
              excerpt.comments.where(comment: /#{params[:comment_search]}/i).each do |_ec|
                query5 << color
              end
            end
          end
        else
          query5 = nil
        end

        temp = all_colors_set

        temp = (temp & query1) unless query1.empty?
        temp = (temp & query2) unless query2.nil?
        temp = (temp & query3) unless query3.nil?
        temp = (temp & query4) unless query4.nil?
        temp = (temp & query6) unless query6.nil?
        temp = (temp & query7) unless query7.nil?
        temp = (temp & query8) unless query8.nil?
        temp = (temp & query5) unless query5.nil?
        @btoe_colors << temp if temp != all_colors_set
      end

      ret = []
      @btoe_colors.each do |color|
        color.each do |b|
          ret << b
        end
      end

      @btoe_colors = ret

      comment_search = params[:comment_search]

      @destacados = cria_destacados(search_term_content, comment_search)

      @@all_colors = @btoe_colors
      @btoe_colors = Kaminari.paginate_array(@btoe_colors).page(params[:page]).per(5)

      if @btoe_colors.count > 0
        respond_to do |format|
          # format.html { render "batale/texts/index" }
          format.js
        end
      else
        # TODO: OLhar aqui --->> Deixar isso?
        # render partial: "shared/search_alert", locals: { msg: "A busca não encontrou resultados." }
        render js: "$('#colors-info').html('Não foram encontradas cores');
                    notification = document.querySelector('.mdl-snackbar');
                    data = { message: 'Não foram encontradas cores.', timeout: 3000};
                    notification.MaterialSnackbar.showSnackbar(data);"
      end
    end
  end

  # GET /btoe/colors/1
  # GET /btoe/colors/1.json
  def show
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Cores', btoe_colors_path
    add_breadcrumb @btoe_color.tag.to_s, btoe_color_path(@btoe_color)

    @btoe_texts = []
    @btoe_color.excerpts.each do |e|
      @btoe_texts << Btoe::Text.find(e.text_id)
    rescue Exception
    end
    @btoe_child_comments = []
    @btoe_color.comments.each do |comment|
      comment.child_comments.each { |c| @btoe_child_comments << c } if comment.child_comments?
    end
    @btoe_child_comments
    @btoe_excerpts_comments = []
    @btoe_color.excerpts.each do |excerpt|
      excerpt.comments.each { |c| @btoe_excerpts_comments << c } if excerpt.comments?
    end
    @btoe_excerpts_comments
  end

  # GET /btoe/colors/new
  def new
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Cores', btoe_colors_path
    add_breadcrumb 'Criando nova cor', new_btoe_color_path
    @btoe_color = authorize Btoe::Color.new
  end

  # GET /btoe/colors/1/edit
  def edit
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Cores', btoe_color_path
    add_breadcrumb "Editando #{@btoe_color.tag}", edit_btoe_color_path(@btoe_color)
  end

  # POST /btoe/colors
  # POST /btoe/colors.json
  def create
    @btoe_color = authorize Btoe::Color.new(btoe_color_params)
    @btoe_color.user = current_user
    respond_to do |format|
      if @btoe_color.save
        format.html { redirect_to @btoe_color, notice: 'Cor criada com sucesso.' }
        format.json { render :show, status: :created, location: @btoe_color }
      else
        format.html { render :new }
        format.json { render json: @btoe_color.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /btoe/colors/1
  # PATCH/PUT /btoe/colors/1.json
  def update
    respond_to do |format|
      if @btoe_color.update(btoe_color_params)
        format.html { redirect_to @btoe_color, notice: 'Cor editada com sucesso.' }
        format.json { render :show, status: :ok, location: @btoe_color }
      else
        format.html { render :edit }
        format.json { render json: @btoe_color.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /btoe/colors/1
  # DELETE /btoe/colors/1.json
  def destroy
    @btoe_color.destroy
    respond_to do |format|
      format.html { redirect_to btoe_colors_url, notice: 'Cor deletada com sucesso.' }
      format.js { render inline: 'location.reload();', notice: 'Cor deletada com sucesso.' }
      format.json { head :no_content }
    end
  end

  def createColor
    params.require(%i[tag hex_color]) # só pra garantir que existem os parametros certos
    btoe_color = authorize Btoe::Color.new(
      tag: params[:tag],
      hex_color: params[:hex_color],
      user_id: current_user
    )
    btoe_color.save!
  end

  def associateColor
    params.require(%i[trechos color_id texto_id create_bloc]) # só pra garantir que existem os parametros certos

    color = Btoe::Color.find(params[:color_id])
    params[:trechos].each do |trecho|
      color.excerpts << Excerpt.new(trecho: trecho, text_id: params[:texto_id], user_id: current_user.id)
    end
    color.save

    if params[:create_bloc]
      bloc = Btoe::Bloc.where(nome: color.tag)[0]

      if bloc.nil?
        bloc = Btoe::Bloc.new(nome: color.tag,
                              descricao: "Bloco criado automaticamente ao associar trecho à cor #{color.tag}",
                              private: false) # false como padrão ??
        bloc.user = current_user
        bloc.save!
      end

      params[:trechos].each do |trecho|
        bloc.excerpts << Excerpt.new(trecho: trecho, text_id: params[:texto_id], user_id: current_user.id)
      end

      bloc.save && color.save
    end
  end

  def addComment
    params.require(%i[color_id comment])
    color = Btoe::Color.find(params[:color_id])
    color.comments.create(comment: params[:comment], user_id: current_user.id)
    color.save!
  end

  def commentExcerpt
    params.require(%i[color_id excerpt_id comment])
    color = Btoe::Color.find(params[:color_id])
    excerpt = color.excerpts.find(params[:excerpt_id])
    excerpt.comments.create(comment: params[:comment], user_id: current_user.id)
    excerpt.save!
    color.save!
  end

  def commentComment
    params.require(%i[color_id comment_id comment])
    color = Btoe::Color.find(params[:color_id])
    comment = color.comments.find(params[:comment_id])
    comment.child_comments.create(comment: params[:comment], user_id: current_user.id)
    comment.save!
    color.save!
  end

  def destroyColorExcerpt
    puts "na destroyColorExcerpt #{params[:color_id]}'"
    puts params.to_json
    params.require(%i[color_id excerpt_id])

    puts params[:color_id]
    color = Btoe::Color.find(params[:color_id])

    if params[:excerpt_id].class == [].class
      params[:excerpt_id].each do |id|
        color.excerpts.find(id).destroy
      end
    else
      color.excerpts.find(params[:excerpt_id]).destroy
    end

    color.save
    respond_to do |format|
      format.js { render inline: 'location.reload();', notice: 'A associação foi deletada com sucesso.' }
    end
  end

  def download_pdf
    # params.require([:color_id])
    if params[:color_id] != ''
      btoe_color = Btoe::Color.find(params[:color_id])
      pdf = helpers.pdf(btoe_color, params)
      path_to_file = "public/btoe/color/#{btoe_color.tag}.pdf"
    else
      pdf = helpers.pdf(@@all_colors, params.merge(@@params))
      path_to_file = "public/btoe/color/Coleção_de_#{@@all_colors.count}_cores.pdf"
    end
    Dir.mkdir('public/btoe') if Dir.glob('public/btoe') == []
    Dir.mkdir('public/btoe/color') if Dir.glob('public/btoe/color') == []
    pdf.render_file(path_to_file)

    respond_to do |format|
      @file_name = "btoe_color_download?file=#{path_to_file}"
      format.js { render partial: 'download_color', notice: 'Baixando arquivo.' }
    end
  end

  def ajax_download
    send_file params[:file]
    Dir.glob('public/btoe/color/*.pdf') do |item|
      FileUtils.rm_f(item) if item != params[:file]
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_btoe_color
    @btoe_color = authorize Btoe::Color.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def btoe_color_params
    params.require(:btoe_color).permit(:hex_color, :tag, :trechos, :user_id)
  end

  def cria_destacados(search_term_content, comment_search)
    if (search_term_content != '') || (comment_search != '')
      destacados = {}
      destacados[:trechos] = {}
      destacados[:comentarios] = {}
      stc_downcase = search_term_content.downcase.split(';').sort_by(&:length).reverse
      comment_search_downcase = comment_search.downcase.split(';').sort_by(&:length).reverse

      @btoe_colors.each_with_index do |color, i|
        color.excerpts.each do |exc|
          trecho_downcase = exc.trecho.downcase
          marcado = ''
          stc_downcase.each do |term|
            next unless trecho_downcase.include?(term) && (search_term_content != '')
            until trecho_downcase.empty?
              antes, trecho, resto = trecho_downcase.partition(term)
              marcado += antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>'
              trecho_downcase = resto
            end
            trecho_downcase = marcado
            marcado = ''

            destacados[:trechos][i] = [] if destacados[:trechos][i].nil?
            destacados[:trechos][i] << trecho_downcase + view_context.link_to(Btoe::Text.find(exc.text_id).codigo_texto, btoe_text_path(exc.text_id), class: 'bloc-link-to-original-text')
          end

          exc.comments.each do |comment|
            comment_downcase = comment.comment.downcase # comment.class -> Btoe::Comment, comment.comment.class -> String
            marcado = ''

            comment_search_downcase.each do |term|
              next unless comment_downcase.include?(term) && (comment_search != '')
              until comment_downcase.empty?
                antes, trecho, resto = comment_downcase.partition(term)
                marcado += antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>'
                comment_downcase = resto
              end
              comment_downcase = marcado
              marcado = ''
              destacados[:comentarios][i] = [] if destacados[:comentarios][i].nil?
              destacados[:comentarios][i] << comment_downcase
            end
          end
        end

        color.comments.each do |comment|
          comment_downcase = comment.comment.downcase
          marcado = ''

          comment_search_downcase.each do |term|
            next unless comment_downcase.include?(term) && (comment_search != '')
            until comment_downcase.empty?
              antes, trecho, resto = comment_downcase.partition(term)
              marcado += antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>'
              comment_downcase = resto
            end
            comment_downcase = marcado
            marcado = ''
            destacados[:comentarios][i] = [] if destacados[:comentarios][i].nil?
            destacados[:comentarios][i] << comment_downcase
          end

          comment.child_comments.each do |cc|
            cc_comment_downcase = cc.comment.downcase
            marcado = ''

            comment_search_downcase.each do |term|
              next unless comment_downcase.include?(term) && (comment_search != '')
              until cc_comment_downcase.empty?
                antes, trecho, resto = cc_comment_downcase.partition(term)
                marcado += antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>'
                cc_comment_downcase = resto
              end
              cc_comment_downcase = marcado
              marcado = ''
              destacados[:comentarios][i] = [] if destacados[:comentarios][i].nil?
              destacados[:comentarios][i] << comment_downcase
            end
          end
        end
      end
      destacados
    end
  end
end
