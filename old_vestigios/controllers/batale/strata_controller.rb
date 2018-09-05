class Batale::StrataController < ApplicationController
  def new
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', batale_texts_path
    add_breadcrumb 'Inserindo informações de estrato', new_batale_stratum_path
    @batale_stratum = Batale::Stratum.new
  end

  def create
    @batale_stratum = Batale::Stratum.new(batale_stratum_params)

    respond_to do |format|
      if @batale_stratum.save
        format.html { redirect_to batale_texts_path, notice: 'Informações adicionadas com sucesso.' }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @batale_stratum = Batale::Stratum.find(params[:id])
    add_breadcrumb 'Início', dashboard_path
    add_breadcrumb 'Textos', batale_texts_path
    add_breadcrumb 'Editando informações de estrato', edit_batale_stratum_path(@batale_stratum)
  end

  def update
    @batale_stratum = Batale::Stratum.find(params[:id])
    respond_to do |format|
      if @batale_stratum.update(batale_stratum_params)
        format.html { redirect_to batale_texts_path, notice: 'Informações do estrato editadas com sucesso.' }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def batale_stratum_params
    params.require(:batale_stratum).permit(:numero_estrato, :ano_coleta, :material_coletado, :tipo_coleta, :serie_ano_coleta, :local_coleta, :escola, :quantidade_de_textos)
  end
end
