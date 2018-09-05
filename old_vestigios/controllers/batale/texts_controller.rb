class Batale::TextsController < ApplicationController
  before_action :set_batale_text, only: %i[show edit update destroy]

  # GET /batale/texts
  # GET /batale/texts.json
  def index
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', batale_texts_path

    project = { '$project': { numero_estrato: '$numero_estrato' } }
    group = { '$group': { '_id': { numero_estrato: '$numero_estrato' }, count: { '$sum': 1 } } }
    sort = { "$sort": { "_id.numero_estrato": 1 } }
    @estratos = []
    Batale::Text.collection.aggregate([project, group, sort]).to_a.each do |elem|
      estrato = elem['_id']['numero_estrato']
      @estratos << { numero_estrato: estrato, count: elem['count'] } if estrato != ''
    end
    @estratos = Kaminari.paginate_array(@estratos).page(params[:page]).per(12)
    @model_estratos = Batale::Stratum.all
    puts @estratos
  end

  def see_more
    unless params[:btn_clear].nil?
      index
      return
    end

    estrato = params[:numero_estrato]
    if estrato.nil?
      estrato = params[:stratum]
      # render partial: "shared/search_alert", locals: { msg: "Algo de errado com a sigla. Voltando." }
      redirect_to batale_texts_path if estrato.nil?
    end

    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', batale_texts_path
    add_breadcrumb "Estrato #{estrato}", batale_see_more_path

    params[:per_page] ||= 5

    if params[:search_content].nil?
      # @batale_texts = authorize Batale::Text.all.page(params[:page]).per(5)
      @@criteria = Batale::Text.where(numero_estrato: estrato)
      @batale_texts = authorize Batale::Text.where(numero_estrato: estrato).page(params[:page]).per(params[:per_page])
      @@params = request.query_parameters
      session[:search_params] = request.query_parameters
    else
      @@criteria = Batale::Text.search(params)
      @batale_texts = Batale::Text.search(params).page(params[:page]).per(params[:per_page])
      @@params = request.query_parameters
      session[:search_params] = request.query_parameters
      if @batale_texts.count > 0
        @destacados = cria_destacados(params['search_content'])
        respond_to do |format|
          # format.html { render "batale/texts/index" }
          format.js
        end
      else
        # TODO: OLhar aqui --->> Deixar isso?
        # render partial: "shared/search_alert", locals: { msg: "A busca não encontrou resultados." }
        render js: "$('#text-info').html('Não foram encontrados textos');
                    notification = document.querySelector('.mdl-snackbar');
                    data = { message: 'Não foram encontrados textos.', timeout: 3000};
                    notification.MaterialSnackbar.showSnackbar(data);"
      end
    end
  end

  def search
    puts @batale_texts.to_json
  end

  # GET /batale/texts/1
  # GET /batale/texts/1.json
  def show
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', batale_texts_path
    add_breadcrumb "Estrato #{@batale_text.numero_estrato}", batale_see_more_path(numero_estrato: @batale_text.numero_estrato)
    add_breadcrumb @batale_text.codigo_texto, batale_text_path(@batale_text)
    @batale_blocs = Batale::Bloc.all.order_by(created_at: 'desc')
    @definitions = Batale::Definition.all
    @batale_errortogs = Batale::Errortog.get_all_errortogs

    session[:search_params] = {} if session[:search_params].nil?
    session[:search_params].merge(request.query_parameters)
    @proximo, @anterior = next_and_previous_texts
  end

  # GET /batale/texts/new
  def new
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', batale_texts_path
    add_breadcrumb 'Criando novo texto', new_batale_text_path
    @batale_text = authorize Batale::Text.new
  end

  # GET /batale/texts/1/edit
  def edit
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', batale_texts_path
    add_breadcrumb "Editando #{@batale_text.codigo_texto}", edit_batale_text_path(@batale_text)
  end

  # POST /batale/texts
  # POST /batale/texts.json
  def create
    @batale_text = authorize Batale::Text.new(batale_text_params)
    @batale_text.cria_codigo_texto

    respond_to do |format|
      if @batale_text.save
        format.html { redirect_to @batale_text, notice: 'Texto criado com sucesso.' }
        format.json { render :show, status: :created, location: @batale_text }
      else
        format.html { render :new }
        format.json { render json: @batale_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batale/texts/1
  # PATCH/PUT /batale/texts/1.json
  def update
    respond_to do |format|
      if @batale_text.update(batale_text_params)
        format.html { redirect_to @batale_text, notice: 'Texto editado com sucesso.' }
        format.json { render :show, status: :ok, location: @batale_text }
      else
        format.html { render :edit }
        format.json { render json: @batale_text.errors, status: :unprocessable_entity }
      end
    end
  end

  def associate_definition
    batale_text = Batale::Text.find(params[:id])
    def_ids = params[:id_def]
    antes, errada, depois = batale_text.texto_normatizado.partition(params[:palavra_errada])
    # batale_text.texto_normatizado = antes + params[:palavra_correta] + depois
    batale_text.texto_highlighted = params[:texto_highlighted]
    def_ids.each do |id|
      definition = Batale::Definition.find(id)
      definition.words.create(
        wrong: params[:palavra_errada],
        right: params[:palavra_correta],
        tag_id: params[:tag_id],
        text_id: params[:id]
      )
      batale_text.definitions << definition
      definition.texts << batale_text
      batale_text.save!
      definition.save!
    end
  end

  def delete_association
    batale_text = Batale::Text.find(params[:id])
    definition = Batale::Definition.find(params[:id_def])
    if params[:palavras].nil?
      batale_text.definition_ids.delete(definition.id)
      definition.text_ids.delete(batale_text.id)
      definition.words.where(text_id: batale_text.id).each(&:destroy!)
      definition.save!
    else
      palavras = params[:palavras]
      palavras.each do |palavra|
        definition.words.each do |word|
          word.destroy! if palavra == word.tag_id && word.text_id.to_s == params[:id]
        end
        definition.save!
      end
      batale_text.definition_ids.delete(definition.id) if definition.words == []
    end
    batale_text.texto_highlighted = params[:texto_highlighted]
    batale_text.save!
  end

  def update_text_highlihgted
    batale_text = Batale::Text.find(params[:id])
    batale_text.texto_highlighted = params[:texto_highlighted]
    batale_text.save!
  end

  def update_texto_normatizado
    params.require([:id])
    batale_text = Batale::Text.find(params[:id])
    batale_text.texto_normatizado = params[:texto_normatizado].chomp
    batale_text.save!
  end

  # DELETE /batale/texts/1
  # DELETE /batale/texts/1.json
  def destroy
    path = 'public/uploads/batale/text/image/' + @batale_text.id
    FileUtils.remove_dir(path) unless Dir.glob(path).empty? # Remove imagem associada ao texto, caso exista
    @batale_text.destroy
    respond_to do |format|
      format.html { redirect_to batale_texts_url, notice: 'Texto deletado com sucesso.' }
      format.json { head :no_content }
    end
  end

  def next_and_previous_texts
    textos = Batale::Text.search(session[:search_params])
    index = textos.find_index(@batale_text)
    next_text = nil
    previous = nil
    unless index.nil?
      next_text = Batale::Text.find(textos[index + 1].id) unless textos[index + 1].nil?
      previous = Batale::Text.find(textos[index - 1].id) if index - 1 >= 0
    end
    [next_text, previous]
  end

  def download_pdf
    pdf = helpers.pdf(@@criteria, @@params.merge(params))
    path_to_file = "public/batale/text/colecao_de_#{@@criteria.count}_textos.pdf"
    Dir.mkdir('public/batale') if Dir.glob('public/batale') == []
    Dir.mkdir('public/batale/text') if Dir.glob('public/batale/text') == []
    pdf.render_file(path_to_file)

    respond_to do |format|
      @file_name = "batale_text_download?file=#{path_to_file}"
      format.js { render partial: 'download_text', notice: 'Baixando arquivo.' }
    end
  end

  def ajax_download
    send_file params[:file]
    Dir.glob('public/batale/text/*.pdf') do |item|
      FileUtils.rm_f(item) if item != params[:file]
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_batale_text
    @batale_text = authorize Batale::Text.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def batale_text_params
    params.require(:batale_text).permit(
      :codigo_texto, :nome_aluno, :numero_aluno,
      :idade, :sexo, :numero_estrato, :numero_coleta,
      :numero_texto, :ano_coleta, :tipo_texto, :escola_crianca,
      :serie, :turma, :texto_original, :texto_normatizado, :texto_highlighted,
      :image, :tipo_escrita
    )
  end

  def cria_destacados(search_term_content)
    if !search_term_content.nil? && (search_term_content != '')
      destacados = {}
      stc_downcase = search_term_content.downcase
      termos = stc_downcase.split(';').sort_by(&:length).reverse
      @batale_texts.each_with_index do |text, i|
        text = text.texto_original.downcase
        marcado = ''
        termos.each do |termo|
          until text.empty?
            antes, trecho, resto = text.partition(termo)
            marcado += antes + '<span style="background-color: rgb(244, 255, 129);">' + trecho + '</span>'

            text = resto
          end
          text = marcado
          marcado = ''
        end
        destacados[i] = text
      end
      destacados
    end
  end
end
