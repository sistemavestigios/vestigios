class Btoe::TextsController < ApplicationController
  before_action :set_btoe_text, only: %i[show edit update destroy]

  # GET /btoe/texts
  # GET /btoe/texts.json
  def index
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', btoe_texts_path

    # Busca movida para o see_more

    project = { '$project': { sigla: '$sigla' } }
    group = { '$group': { '_id': { sigla: '$sigla' }, count: { '$sum': 1 } } }
    @siglas = []
    Btoe::Text.collection.aggregate([project, group]).to_a.each do |elem|
      sigla = elem['_id']['sigla']
      @siglas << { sigla: sigla, count: elem['count'] } if sigla != ''
    end
    @siglas = Kaminari.paginate_array(@siglas).page(params[:page]).per(12)
  end

  def see_more
    unless params[:btn_clear].nil?
      index
      return
    end

    sigla = params[:sigla]
    if sigla.nil?
      # render partial: "shared/search_alert", locals: { msg: "Algo de errado com a sigla. Voltando." }
      redirect_to btoe_texts_path
    end
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', btoe_texts_path
    add_breadcrumb sigla, btoe_see_more_path

    params[:per_page] ||= 5

    # if params[:search].nil?
    # :search saiu e ficou só o :content, pois toda busca agora é "avançada"
    if params[:content].nil?
      # TODO: tratar possíveis exceções do mongo
      @@criteria = Btoe::Text.where(sigla: sigla)
      @btoe_texts = authorize Btoe::Text.where(sigla: sigla).page(params[:page]).per(params[:per_page])
      @@params = request.query_parameters
      session[:search_params] = request.query_parameters
    else
      @@criteria = Btoe::Text.search(params)
      @btoe_texts = Btoe::Text.search(params).page(params[:page]).per(params[:per_page])
      @@params = request.query_parameters
      session[:search_params] = request.query_parameters
      if @btoe_texts.count > 0
        @destacados = cria_destacados(params['content'])
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

  # GET /btoe/texts/1
  # GET /btoe/texts/1.json
  def show
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', btoe_texts_path
    add_breadcrumb @btoe_text.sigla, btoe_see_more_path(sigla: @btoe_text.sigla)
    add_breadcrumb @btoe_text.codigo_texto, btoe_text_path(@btoe_text)

    session[:search_params] = {} if session[:search_params].nil?
    session[:search_params].merge(request.query_parameters)
    @proximo, @anterior = next_and_previous_texts

    @btoe_blocs = Btoe::Bloc.all.order_by(created_at: 'desc')
    @associated_blocs = @btoe_text.find_associated_blocs
    @btoe_colors = Btoe::Color.all.order_by(created_at: 'desc')
    @associated_colors_and_excerpts = @btoe_text.find_associated_colors_and_excerpts(current_user.id)
    @color_chips = {}
    @color_chips[:all] = {}
    @color_chips[:user] = {}
    @associated_colors_and_excerpts[:all].each do |ace|
      @color_chips[:all][ace[:color]] = [] if @color_chips[:all][ace[:color]].nil?
      @color_chips[:all][ace[:color]] << ace[:excerpt]
    end
    @associated_colors_and_excerpts[:user].each do |ace|
      @color_chips[:user][ace[:color]] = [] if @color_chips[:user][ace[:color]].nil?
      @color_chips[:user][ace[:color]] << ace[:excerpt]
    end
    @marked_text = mark_text

    counter = WordsCounted.count(@btoe_text.texto_full, exclude: get_stop_words)
    @dados = []
    counter.token_frequency.each do |slice|
      @dados << slice if slice[1] > 1
    end
  end

  # GET /btoe/texts/new
  def new
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', btoe_texts_path
    add_breadcrumb 'Criando novo texto', new_btoe_text_path
    @btoe_text = authorize Btoe::Text.new
  end

  # GET /btoe/texts/1/edit
  def edit
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', btoe_texts_path
    add_breadcrumb "Editando #{@btoe_text.codigo_texto}", edit_btoe_text_path(@btoe_text)
  end

  # POST /btoe/texts
  # POST /btoe/texts.json
  def create
    @btoe_text = authorize Btoe::Text.new(btoe_text_params)

    respond_to do |format|
      if @btoe_text.save
        format.html { redirect_to @btoe_text, notice: 'Texto criado com sucesso.' }
        format.json { render :show, status: :created, location: @btoe_text }
      else
        format.html { render :new }
        format.json { render json: @btoe_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /btoe/texts/1
  # PATCH/PUT /btoe/texts/1.json
  def update
    respond_to do |format|
      if @btoe_text.update(btoe_text_params)
        @btoe_text.update_codigo_texto!
        format.html { redirect_to @btoe_text, notice: 'Texto editado com sucesso.' }
        format.json { render :show, status: :ok, location: @btoe_text }
      else
        format.html { render :edit }
        format.json { render json: @btoe_text.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /btoe/texts/1
  # DELETE /btoe/texts/1.json
  def destroy
    path = 'public/uploads/btoe/text/image/' + @btoe_text.id
    FileUtils.remove_dir(path) unless Dir.glob(path).empty? # Remove imagem associada ao texto, caso exista
    @btoe_text.destroy
    respond_to do |format|
      format.html { redirect_to btoe_texts_url, notice: 'Texto deletado com sucesso.' }
      format.json { head :no_content }
    end
  end

  def print
    @btoe_text = Btoe::Text.find(params[:id])
  end

  def download_pdf
    params.require(:text_id)
    btoe_text = Btoe::Text.find(params[:text_id])
    user_id = params[:show_associations_of] == 'user' ? current_user.id : nil
    helpers.pdf(btoe_text, show_associations_of: user_id)
    path_to_file = "public/btoe/text/#{btoe_text.codigo_texto.tr('/', '-')}.pdf"
    respond_to do |format|
      @file_name = "btoe_text_download?file=#{path_to_file}"
      format.js { render partial: 'download_text', notice: 'Baixando arquivo.' }
    end
  end

  def ajax_download
    send_file params[:file]
    Dir.glob('public/btoe/text/*.pdf') do |item|
      FileUtils.rm_f(item) if item != params[:file]
    end
  end

  def next_and_previous_texts
    textos = Btoe::Text.search(session[:search_params])
    index = textos.find_index(@btoe_text)
    next_text = nil
    previous = nil
    unless index.nil?
      next_text = Btoe::Text.find(textos[index + 1].id) unless textos[index + 1].nil?
      previous = Btoe::Text.find(textos[index - 1].id) if index - 1 >= 0
    end
    [next_text, previous]
  end

  def download_texts_pdf
    pdf = helpers.pdf(@@criteria, @@params.merge(params))
    path_to_file = "public/btoe/text/colecao_de_#{@@criteria.count}_textos.pdf"
    Dir.mkdir('public/btoe') if Dir.glob('public/btoe') == []
    Dir.mkdir('public/btoe/text') if Dir.glob('public/btoe/text') == []
    pdf.render_file(path_to_file)

    respond_to do |format|
      @file_name = "btoe_text_download?file=#{path_to_file}"
      format.js { render partial: 'download_text', notice: 'Baixando arquivo.' }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_btoe_text
    @btoe_text = authorize Btoe::Text.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def btoe_text_params
    params.require(:btoe_text).permit(:codigo_texto, :sigla, :ano, :polo, :turma, :numero_professora, :texto_full, :image)
  end

  def mark_text
    if @associated_colors_and_excerpts.nil?
      if @btoe_text.nil?
        puts 'associated_colors_and_excerpts e btoe_text são nil ao executar mercar_texto'
        return nil
      else
        @associated_colors_and_excerpts = @btoe_text.find_associated_colors_and_excerpts(current_user.id)
      end
    end

    color_excerpt = { color: [], excerpt: [] }
    associated = @associated_colors_and_excerpts
    text = @btoe_text.texto_full
    index = {}
    trechos = []
    cores = []
    associated[:user].each do |h|
      h.each do |k, v|
        color_excerpt[k] << (k == :color ? v.hex_color.delete('#') : v.trecho)
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

    a_trechos = ''
    trechos.each_with_index do |trecho, i|
      antes, igual, text = text.partition(trecho)
      igual = "<span class=\"color_#{cores[i].delete('#')}\">" + igual + '</span>'
      a_trechos += antes + igual
    end
    a_trechos += text

    texto_marcado = {}
    texto_marcado[:user] = a_trechos

    text = @btoe_text.texto_full
    color_excerpt = { color: [], excerpt: [] }
    index = {}
    trechos = []
    cores = []
    associated[:all].each do |h|
      h.each do |k, v|
        color_excerpt[k] << (k == :color ? v.hex_color.delete('#') : v.trecho)
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

    a_trechos = ''
    trechos.each_with_index do |trecho, i|
      antes, igual, text = text.partition(trecho)
      igual = "<span class=\"color_#{cores[i].delete('#')}\">" + igual + '</span>'
      a_trechos += antes + igual
    end
    a_trechos += text
    texto_marcado[:all] = a_trechos

    texto_marcado
  end

  def cria_destacados(search_term_content)
    if !search_term_content.nil? && (search_term_content != '')
      destacados = {}
      stc_downcase = search_term_content.downcase
      termos = stc_downcase.split(';').sort_by(&:length).reverse
      @btoe_texts.each_with_index do |text, i|
        text = text.texto_full.downcase
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
