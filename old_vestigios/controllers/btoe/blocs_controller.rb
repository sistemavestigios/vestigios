class Btoe::BlocsController < ApplicationController
  before_action :set_btoe_bloc, only: %i[show edit update destroy]

  # GET /btoe/blocs
  # GET /btoe/blocs.json
  def index
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Blocos', btoe_blocs_path
    @users = User.all
    @@params = {}
    if params[:search].nil?
      @@all_blocs = authorize Btoe::Bloc.all
      @btoe_blocs = authorize Btoe::Bloc.all.page(params[:page]).per(5)
    else
      @@params = request.query_parameters
      @btoe_blocs = Set.new
      search_term_content = params[:content].gsub ' ', '.*'
      query1 = Set.new
      if params[:search] != ''
        query1 = Set.new(authorize(Btoe::Bloc.search(params)))
      else
        if search_term_content == '' && params[:ano] == '' &&
           params[:turma] == '' && params[:comment_search] == '' &&
           params[:sigla] == '' && params[:numero_professora] == '' &&
           params[:polo] == ''
          @btoe_blocs = authorize Btoe::Bloc.all.page(params[:page]).per(5)
          return @btoe_blocs
        end
      end

      all_blocs = Btoe::Bloc.all
      all_blocs_set = all_blocs.to_set

      all_blocs.each do |bloc|
        # busca por conteudo(trecho) dos excerpts
        query2 = Set.new
        if search_term_content != ''
          queried = bloc.excerpts.where(trecho: /#{search_term_content}/i) || []
          queried.each do |q|
            # itera sobre os excerpts retornados
            query2 << q._parent # e adiciona os blocs respectivos
          end
        else
          query2 = nil
        end

        query3 = Set.new
        if params[:ano] != ''
          bloc.excerpts.each do |excerpt|
            text = Btoe::Text.find(excerpt.text_id)
            query3 << bloc if text.ano == params[:ano].to_i
          end
        else
          query3 = nil
        end

        query4 = Set.new
        if params[:turma] != ''
          bloc.excerpts.each do |excerpt|
            text = Btoe::Text.find(excerpt.text_id)
            query4 << bloc if text.turma == params[:turma].to_i
          end
        else
          query4 = nil
        end

        query6 = Set.new
        if params[:sigla] != ''
          bloc.excerpts.each do |excerpt|
            text = Btoe::Text.find(excerpt.text_id)
            query6 << bloc if /#{params[:sigla]}/i.match?(text.sigla)
          end
        else
          query6 = nil
        end

        query7 = Set.new
        if params[:polo] != ''
          bloc.excerpts.each do |excerpt|
            text = Btoe::Text.find(excerpt.text_id)
            query7 << bloc if /#{params[:polo]}/i.match?(text.polo)
          end
        else
          query7 = nil
        end

        query8 = Set.new
        if params[:numero_professora] != ''
          bloc.excerpts.each do |excerpt|
            text = Btoe::Text.find(excerpt.text_id)
            query8 << bloc if /#{params[:numero_professora]}/i.match?(text.numero_professora)
          end
        else
          query8 = nil
        end

        query5 = Set.new
        if params[:comment_search] != ''
          bloc.comments.where(comment: /#{params[:comment_search]}/i).each do |_comment|
            query5 << bloc
          end
          bloc.comments.each do |comment|
            comment.child_comments.where(comment: /#{params[:comment_search]}/i).each do |_cc|
              query5 << bloc
            end
          end
          bloc.excerpts.each do |excerpt|
            excerpt.comments.where(comment: /#{params[:comment_search]}/i).each do |_ec|
              query5 << bloc
            end
          end
        else
          query5 = nil
        end

        temp = all_blocs_set

        temp = (temp & query1) unless query1.empty?
        temp = (temp & query2) unless query2.nil?
        temp = (temp & query3) unless query3.nil?
        temp = (temp & query4) unless query4.nil?
        temp = (temp & query6) unless query6.nil?
        temp = (temp & query7) unless query7.nil?
        temp = (temp & query8) unless query8.nil?
        temp = (temp & query5) unless query5.nil?
        @btoe_blocs << temp if temp != all_blocs_set
      end

      ret = []
      @btoe_blocs.each do |bloc|
        bloc.each do |b|
          ret << b
        end
      end

      @btoe_blocs = ret

      comment_search = params[:comment_search]

      if (search_term_content != '') || (comment_search != '')
        @destacados = {}
        @destacados[:trechos] = {}
        @destacados[:comentarios] = {}
        stc_downcase = search_term_content.downcase
        comment_search_downcase = comment_search.downcase
        @btoe_blocs.each_with_index do |bloc, i|
          bloc.excerpts.each do |exc|
            trecho_downcase = exc.trecho.downcase
            # stc_downcase = search_term_content.downcase
            if trecho_downcase.include?(stc_downcase) && (search_term_content != '')
              antes, trecho, depois = trecho_downcase.partition(stc_downcase)
              @destacados[:trechos][i] = [] if @destacados[:trechos][i].nil?
              @destacados[:trechos][i] << antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>' + depois + view_context.link_to(Btoe::Text.find(exc.text_id).codigo_texto, btoe_text_path(exc.text_id), class: 'bloc-link-to-original-text')
            end
            exc.comments.each do |comment|
              comment_downcase = comment.comment.downcase # comment.class -> Btoe::Comment, comment.comment.class -> String
              next unless comment_downcase.include?(comment_search_downcase) && (comment_search != '')
              antes, trecho, depois = comment_downcase.partition(comment_search_downcase)
              @destacados[:comentarios][i] = [] if @destacados[:comentarios][i].nil?
              @destacados[:comentarios][i] << antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>' + depois
            end
          end
          bloc.comments.each do |comment|
            comment_downcase = comment.comment.downcase
            # comment_search_downcase = comment_search.downcase
            if comment_downcase.include?(comment_search_downcase) && (comment_search != '')
              antes, trecho, depois = comment_downcase.partition(comment_search_downcase)
              @destacados[:comentarios][i] = [] if @destacados[:comentarios][i].nil?
              @destacados[:comentarios][i] << antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>' + depois
            end
            comment.child_comments.each do |cc|
              cc_comment_downcase = cc.comment.downcase
              comment_search_downcase = comment_search.downcase
              next unless cc_comment_downcase.include?(comment_search_downcase) && (comment_search != '')
              antes, trecho, depois = comment_search_downcase.partition(comment_search_downcase)
              @destacados[:comentarios][i] = [] if @destacados[:comentarios][i].nil?
              @destacados[:comentarios][i] << antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>' + depois
            end
          end
        end
      end

      @@all_blocs = @btoe_blocs
      @btoe_blocs = Kaminari.paginate_array(@btoe_blocs).page(params[:page]).per(5)

      if @btoe_blocs.count > 0
        respond_to do |format|
          # format.html { render "batale/texts/index" }
          format.js
        end
      else
        # TODO: OLhar aqui --->> Deixar isso?
        # render partial: "shared/search_alert", locals: { msg: "A busca não encontrou resultados." }
        render js: "$('#blocs-info').html('Não foram encontrados blocos');
                    notification = document.querySelector('.mdl-snackbar');
                    data = { message: 'Não foram encontrados blocos.', timeout: 3000};
                    notification.MaterialSnackbar.showSnackbar(data);"
      end
    end
  end

  # GET /btoe/blocs/1
  # GET /btoe/blocs/1.json
  def show
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Blocos', btoe_blocs_path
    add_breadcrumb @btoe_bloc.nome.to_s, btoe_bloc_path(@btoe_bloc)
    @btoe_texts = []
    @btoe_bloc.excerpts.each do |e|
      @btoe_texts << Btoe::Text.find(e.text_id)
    rescue Exception
    end
    generate_statistics
    @btoe_child_comments = []
    @btoe_bloc.comments.each do |comment|
      comment.child_comments.each { |c| @btoe_child_comments << c } if comment.child_comments?
    end
    @btoe_child_comments
    @btoe_excerpts_comments = []
    @btoe_bloc.excerpts.each do |excerpt|
      excerpt.comments.each { |c| @btoe_excerpts_comments << c } if excerpt.comments?
    end
  end

  # GET /btoe/blocs/new
  def new
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Blocos', btoe_blocs_path
    add_breadcrumb 'Criando novo bloco', new_btoe_bloc_path
    @btoe_bloc = authorize Btoe::Bloc.new
  end

  # GET /btoe/blocs/1/edit
  def edit
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Blocos', btoe_blocs_path
    add_breadcrumb "Editando #{@btoe_bloc.nome}", edit_btoe_bloc_path(@btoe_bloc)
  end

  # POST /btoe/blocs
  # POST /btoe/blocs.json
  def create
    @btoe_bloc = authorize Btoe::Bloc.new(btoe_bloc_params)
    @btoe_bloc.user = current_user
    respond_to do |format|
      if @btoe_bloc.save
        format.html { redirect_to @btoe_bloc, notice: 'Bloco criado com sucesso.' }
        format.json { render :show, status: :created, location: @btoe_bloc }
      else
        format.html { render :new }
        format.json { render json: @btoe_bloc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /btoe/blocs/1
  # PATCH/PUT /btoe/blocs/1.json
  def update
    respond_to do |format|
      if @btoe_bloc.update(btoe_bloc_params)
        format.html { redirect_to @btoe_bloc, notice: 'Bloco editado com sucesso.' }
        format.json { render :show, status: :ok, location: @btoe_bloc }
      else
        format.html { render :edit }
        format.json { render json: @btoe_bloc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /btoe/blocs/1
  # DELETE /btoe/blocs/1.json
  def destroy
    @btoe_bloc.comments.each(&:destroy) if @btoe_bloc.comments?
    @btoe_bloc.destroy
    respond_to do |format|
      format.html { redirect_to btoe_blocs_url, notice: 'Bloco deletado com sucesso.' }
      format.json { head :no_content }
    end
  end

  def download_pdf
    if params[:bloc_id] != ''
      btoe_bloc = Btoe::Bloc.find(params[:bloc_id])
      pdf = helpers.pdf(btoe_bloc, params)
      path_to_file = "public/btoe/bloc/#{btoe_bloc.nome.tr('/', '-')}.pdf"
    else
      pdf = helpers.pdf(@@all_blocs, params.merge(@@params))
      path_to_file = "public/btoe/bloc/coleção_de_#{@@all_blocs.count}_blocos.pdf"
    end
    Dir.mkdir('public/btoe') if Dir.glob('public/btoe') == []
    Dir.mkdir('public/btoe/bloc') if Dir.glob('public/btoe/bloc') == []
    pdf.render_file(path_to_file)

    respond_to do |format|
      @file_name = "ajax_get_btoe_bloc_download?file=#{path_to_file}"
      format.js { render partial: 'download_bloc', notice: 'Baixando arquivo.' }
    end
  end

  def ajax_download
    send_file params[:file]
    Dir.glob('public/btoe/bloc/*.pdf') do |item|
      FileUtils.rm_f(item) if item != params[:file]
    end
  end

  # POST /saveToBtoeBloc
  def saveToBloc
    params.require(%i[btoe_bloc text_id trechos]) # só pra garantir que existem os parametros certos

    btoe_bloc = Btoe::Bloc.find(params[:btoe_bloc])

    params[:trechos].each do |trecho|
      btoe_bloc.excerpts << Excerpt.new(trecho: trecho, text_id: params[:text_id])
    end
    respond_to do |format|
      if btoe_bloc.save
        format.js { render inline: 'location.reload(true)', notice: 'Trecho adicionado ao bloco com sucesso' }
      else
        format.js { render inline: '', notice: 'Ocorreu um erro ao criar o bloco' }
      end
    end
  end

  def createBloc
    params.require([:name]) # só pra garantir que existem os parametros certos
    btoe_bloc = Btoe::Bloc.new(nome: params[:name], descricao: params[:desc], private: params[:privado])
    btoe_bloc.user = current_user
    btoe_bloc.save!
    # teria que ser por aqui a resposta, eu acho, mas farei pelo js pra ser mais rapido
    # pela limitação de tempo
    respond_to do |format|
      if btoe_bloc.save
        format.js { render inline: 'location.reload(true);', notice: 'Bloco criado com sucesso' }
      else
        format.js { render inline: '', notice: 'Ocorreu um erro ao criar o bloco' }
      end
    end
  end

  def destroyBlocExcerpt
    puts "na destroyBlocExcerpt #{params[:bloc_id]}'"
    puts params.to_json
    params.require(%i[bloc_id excerpt_id])

    puts params[:bloc_id]
    bloc = Btoe::Bloc.find(params[:bloc_id])

    bloc.excerpts.find(params[:excerpt_id]).destroy
    bloc.save
    respond_to do |format|
      format.js { render inline: 'location.reload();', notice: 'A associação foi deletada com sucesso.' }
    end
  end

  def addComment
    params.require(%i[bloc_id comment])
    bloc = Btoe::Bloc.find(params[:bloc_id])
    if params.key?(:excerpt_id)
      # TODO:
    else
      bloc.comments.create(comment: params[:comment], user_id: current_user.id)
      bloc.save
    end
  end

  def commentComment
    params.require(%i[bloc_id comment_id comment])
    bloc = Btoe::Bloc.find(params[:bloc_id])
    comment = bloc.comments.find(params[:comment_id])
    comment.child_comments.create(comment: params[:comment], user_id: current_user.id)
    comment.save!
    bloc.save!
  end

  def commentExcerpt
    params.require(%i[bloc_id excerpt_id comment])
    bloc = Btoe::Bloc.find(params[:bloc_id])
    excerpt = bloc.excerpts.find(params[:excerpt_id])
    excerpt.comments.create(comment: params[:comment], user_id: current_user.id)
    excerpt.save!
    bloc.save!
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_btoe_bloc
    @btoe_bloc = authorize Btoe::Bloc.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def btoe_bloc_params
    params.require(:btoe_bloc).permit(:nome, :descricao, :text_id, :private)
  end

  # para fazer as estatisticas dos textos do bloco
  def generate_statistics
    text_data = {}
    text_data[:ano] = []
    text_data[:turma] = []
    @btoe_texts.each do |text|
      text_data[:ano] << text.ano
      text_data[:turma] << text.turma
    end

    @anos = {}
    text_data[:ano].each do |ano|
      if @anos[ano]
        @anos[ano] += 1
      else
        @anos[ano] = 1
      end
    end
    @turmas = {}
    text_data[:turma].each do |turma|
      if @turmas[turma]
        @turmas[turma] += 1
      else
        @turmas[turma] = 1
      end
    end
  end
end
