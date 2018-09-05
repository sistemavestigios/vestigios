class Batale::ErrortogsController < ApplicationController
  before_action :set_batale_errortog, only: %i[show edit update destroy]
  before_action :set_breadcrumb, except: %i[update destroy download_pdf ajax_download]

  def index
    p params
    if !params.key?(:regra)
      @batale_errortogs = authorize Batale::Errortog.all
    else
      @batale_definitions = Batale::Definition.search(params)
      if @batale_definitions.nil?
        @batale_errortogs = authorize Batale::Errortog.all
      else
        # @select = Batale::Errortog.find(params['select'], nil).child_errortogs
        @batale_definitions = Batale::Definition.search(params)
        @count = @batale_definitions.count
        @batale_definitions = @batale_definitions.class == Array ? Kaminari.paginate_array(@batale_definitions).page(params[:page]).per(5) : @batale_definitions.page(params[:page]).per(5)
      end
    end
  end

  # metodo usado pra gerar os pdfs da listagem de definitions
  def download_pdf
    ary_ids = params['def_ids']
    params.delete_if { |k, _v| %w[def_ids controller action].include? k }
    pdf = helpers.pdf(ary_ids, params)
    path_to_file = 'public/batale/errortog/output.pdf'
    Dir.mkdir('public/batale') if Dir.glob('public/batale') == []
    Dir.mkdir('public/batale/errortog') if Dir.glob('public/batale/errortog') == []
    pdf.render_file(path_to_file)

    respond_to do |format|
      @file_name = "ajax_get_errortog_pdf?file=#{path_to_file}"
      format.js { render partial: 'download_errortog', notice: 'Baixando arquivo.' }
    end
  end

  def ajax_download
    send_file params[:file]
    Dir.glob('public/batale/errortog/*.pdf') do |item|
      FileUtils.rm_f(item) if item != params[:file]
    end
  end

  def show
    add_breadcrumb @batale_errortog.name, batale_errortog_path
    @batale_definitions = @batale_errortog.definitions.page(params[:page]).per(5)
  end

  def new
    add_breadcrumb 'Novo Erro'
    @batale_errortog = authorize Batale::Errortog.new
    @batale_errortog.definitions.build
    @batale_errortog.child_errortogs.build
    @batale_errortogs = Batale::Errortog.get_all_errortogs
  end

  def edit
    add_breadcrumb "Editando #{@batale_errortog.name}", edit_batale_errortog_path(@batale_errortog)
    @batale_errortogs = Batale::Errortog.get_all_errortogs
  end

  def create
    @batale_errortog = authorize Batale::Errortog.new(name: params[:batale_errortog][:name],
                                                      parent_errortog: Batale::Errortog.find(params[:batale_errortog][:parent_errortog]))
    p @batale_errortog.parent_errortog
    respond_to do |format|
      if @batale_errortog.save
        format.html { redirect_to @batale_errortog, notice: 'Classe de erro criada com sucesso' }
        format.json { render :show, status: :created, location: @batale_errortog }
      else
        format.html { render :new }
        format.json { render json: @batale_errortog.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @batale_errortog.save
        format.html { redirect_to @batale_errortog, notice: 'Classe de erro alterada com sucesso' }
        format.json { render :show, status: :ok, location: @batale_errortog }
      else
        format.html { render :edit }
        format.json { render json: @batale_errortog.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @batale_errortog.destroy
    respond_to do |format|
      format.html { redirect_to batale_errortogs_url, notice: 'Erro deletado com sucesso.' }
      format.json { head :no_content }
    end
  end

  def get_definitions
    definitions = {}
    errortogs = Batale::Errortog.get_all_errortogs
    errortogs.each do |err|
      if err.name == params[:name] && err.parent_errortog? ? (err.parent_errortog.name == params[:namePai]) : false
        definitions['name'] = err.name
        definitions['definitions'] = err.definitions
      end
    end
    respond_to do |format|
      format.html { redirect_to batale_definitions_path }
      format.json { render json: definitions }
    end
  end

  private

  def set_batale_errortog
    @batale_errortog = authorize Batale::Errortog.find(params[:id])
  end

  def batale_errortog_params
    params.require(:batale_errortog).permit(:name, :parent_errortog)
  end

  def set_breadcrumb
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Erros', batale_errortogs_path
    if action_name != 'index' && action_name != 'new' && action_name != 'create'
      parent = @batale_errortog.parent_errortog
      parents = []
      while parent.present?
        parents << parent
        parent = parent.parent_errortog
      end
      parents.reverse_each { |parent| add_breadcrumb parent.name }
    end
  end
end
