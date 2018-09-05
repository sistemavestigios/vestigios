class Batale::BlocsController < ApplicationController
  before_action :set_batale_bloc, only: %i[show edit update destroy]

  # GET /batale/blocs
  # GET /batale/blocs.json
  def index
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Blocos', batale_blocs_path

    if params[:search].nil?
      @batale_blocs = authorize Batale::Bloc.all.page(params[:page]).per(5)
    else
      @batale_blocs = authorize Batale::Bloc.search(params).page(params[:page]).per(5)
      if @batale_blocs.count > 0
        respond_to do |format|
          # format.html { render "batale/texts/index" }
          format.js
        end
      else
        # TODO: OLhar aqui --->> Deixar isso?
        # render partial: "shared/search_alert", locals: { msg: "A busca não encontrou resultados." }
        render js: "notification = document.querySelector('.mdl-snackbar');
                    data = { message: 'Não foram encontrados blocos.', timeout: 3000};
                    notification.MaterialSnackbar.showSnackbar(data);"
      end
    end
  end

  # GET /batale/blocs/1
  # GET /batale/blocs/1.json
  def show
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Blocos', batale_blocs_path
    add_breadcrumb @batale_bloc.nome.to_s, batale_bloc_path(@batale_bloc)
    @batale_texts = []
    @batale_bloc.excerpts.each do |e|
      @batale_texts << Batale::Text.find(e.text_id)
    rescue Exception
    end
  end

  # GET /batale/blocs/new
  def new
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Blocos', batale_blocs_path
    add_breadcrumb 'Criando novo bloco', new_batale_bloc_path
    @batale_bloc = authorize Batale::Bloc.new
  end

  # GET /batale/blocs/1/edit
  def edit
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Blocos', batale_blocs_path
    add_breadcrumb "Editando #{@batale_bloc.nome}", edit_batale_bloc_path(@batale_bloc)
  end

  # POST /batale/blocs
  # POST /batale/blocs.json
  def create
    @batale_bloc = authorize Batale::Bloc.new(batale_bloc_params)

    respond_to do |format|
      if @batale_bloc.save
        format.html { redirect_to @batale_bloc, notice: 'Bloco criado com sucesso.' }
        format.json { render :show, status: :created, location: @batale_bloc }
      else
        format.html { render :new }
        format.json { render json: @batale_bloc.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /batale/blocs/1
  # PATCH/PUT /batale/blocs/1.json
  def update
    respond_to do |format|
      if @batale_bloc.update(batale_bloc_params)
        format.html { redirect_to @batale_bloc, notice: 'Bloco editado com sucesso.' }
        format.json { render :show, status: :ok, location: @batale_bloc }
      else
        format.html { render :edit }
        format.json { render json: @batale_bloc.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /batale/blocs/1
  # DELETE /batale/blocs/1.json
  def destroy
    @batale_bloc.destroy
    respond_to do |format|
      format.html { redirect_to batale_blocs_url, notice: 'Bloco deletado com sucesso.' }
      format.json { head :no_content }
    end
  end

  # POST /saveToBtoeBloc
  def saveToBloc
    params.require(%i[batale_bloc text_id trecho]) # só pra garantir que existem os parametros certos

    batale_bloc = Batale::Bloc.find(params[:batale_bloc])

    batale_bloc.excerpts << Excerpt.new(trecho: params[:trecho], text_id: params[:text_id])
  end

  def createBloc
    params.require([:name]) # só pra garantir que existem os parametros certos
    batale_bloc = Batale::Bloc.new(nome: params[:name], descricao: params[:desc])
    batale_bloc.save!
    # teria que ser por aqui a resposta, eu acho, mas farei pelo js pra ser mais rapido
    # pela limitação de tempo
    # respond_to do |format|
    #   if batale_bloc.save
    #     format.js { render partial }
    #   else
    #     format.js { render json: @batale_bloc.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  def destroyBlocExcerpt
    puts "na destroyBlocExcerpt #{params[:bloc_id]}'"
    puts params.to_json
    params.require(%i[bloc_id excerpt_id])

    puts params[:bloc_id]
    bloc = Batale::Bloc.find(params[:bloc_id])

    bloc.excerpts.find(params[:excerpt_id]).destroy
    bloc.save
    respond_to do |format|
      format.js { render inline: 'location.reload();', notice: 'A associação foi deletada com sucesso.' }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_batale_bloc
    @batale_bloc = authorize Batale::Bloc.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def batale_bloc_params
    params.require(:batale_bloc).permit(:nome, :descricao)
  end
end
