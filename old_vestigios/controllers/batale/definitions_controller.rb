class Batale::DefinitionsController < ApplicationController
  before_action :set_batale_definition, only: %i[update create destroy edit show]
  before_action :set_breadcrumb, except: %i[index new create]

  # Metodo usado pra gerar os pdfs da listagem de palavras que tem um determinado erro(definition)
  def download_pdf
    params.require([:definition_id])
    batale_definition = Batale::Definition.find(params[:definition_id])
    params.delete_if { |k, _v| %w[definition_id controller action].include? k }
    pdf = helpers.pdf(batale_definition, params)
    path_to_render = "public/batale/definition/#{batale_definition.regra}.pdf"
    Dir.mkdir('public/batale') if Dir.glob('public/batale') == []
    Dir.mkdir('public/batale/definition') if Dir.glob('public/batale/definition') == []
    pdf.render_file(path_to_render)

    respond_to do |format|
      @file_name = "ajax_get_definition_pdf?file=#{path_to_render}"
      format.js { render partial: 'download_definition', notice: 'Baixando arquivo.' }
    end
  end

  def ajax_download
    send_file params[:file]
    Dir.glob('public/batale/definition/*.pdf') do |item|
      FileUtils.rm_f(item) if item != params[:file]
    end
  end

  def show
    params[:per_page] ||= 5
    @associated_texts = params.key?(:number_student) ? @batale_definition.texts.search(params) : @batale_definition.texts
    @count = @associated_texts.count
    @associated_texts = @associated_texts.page(params[:page]).per(params[:per_page])
  end

  def edit
    add_breadcrumb "Editando #{@batale_definition.regra}", edit_batale_definition_path(@batale_definition)
    @batale_errortogs = Batale::Errortog.get_all_errortogs
  end

  def update
    respond_to do |format|
      if @batale_definition.update(batale_definition_params)
        format.html { redirect_to @batale_definition, notice: 'Classe de erro alterada com sucesso' }
        format.json { render :show, status: :ok, location: @batale_definition }
      else
        format.html { render :edit }
        format.json { render json: @batale_definition.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @batale_definition.destroy
    redirect_back fallback_location: root_path, notice: 'Erro deletado com sucesso.'
  end

  def create_definition
    params.require(:errortog_id)
    errortog = authorize Batale::Errortog.find(params[:errortog_id])
    errortog.definitions.create(regra: params[:regra], exemplo: params[:exemplo], palavra_alvo: params[:palavra_alvo])
    definition = errortog.definitions.last
    definition.errortog_name = errortog.name
    definition.errortogs_ids = definition.parents_ids(errortog)
    definition.save!
    errortog.save!
    redirect_back fallback_location: root_path, notice: 'Definição criada com sucesso.'
  end

  private

  def set_batale_definition
    @batale_definition = authorize Batale::Definition.find(params[:id])
  end

  def batale_definition_params
    params.require(:batale_definition).permit(:regra, :exemplo, :palavra_alvo, :errortog_id,
      excerpts_attributes: %i[id trecho text_id])
  end

  def set_breadcrumb
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Erros',  batale_errortogs_path
    if action_name == 'show'
      parent = @batale_definition.errortog
      parents = []
      while parent.present?
        parents << parent
        parent = parent.parent_errortog
      end
      parents.reverse_each { |parent| add_breadcrumb parent.name }
    end
  end
end
