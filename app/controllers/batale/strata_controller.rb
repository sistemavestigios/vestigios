class Batale::StrataController < ApplicationController
  before_action :set_batale_stratum, only: %i[show edit update destroy]

  def index
    @batale_strata = Batale::Stratum.all
  end

  def show; end

  def new
    @batale_stratum = Batale::Stratum.new
  end

  def edit; end

  def create
    @batale_stratum = Batale::Stratum.new(batale_stratum_params)

    if @batale_stratum.save
      redirect_to @batale_stratum, notice: 'Stratum was successfully created.'
    else
      render :new
    end
  end

  def update
    if @batale_stratum.update(batale_stratum_params)
      redirect_to @batale_stratum, notice: 'Stratum was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @batale_stratum.destroy
    redirect_to batale_strata_url, notice: 'Stratum was successfully destroyed.'
  end

  private

  def set_batale_stratum
    @batale_stratum = Batale::Stratum.find(params[:id])
  end

  def batale_stratum_params
    params
      .require(:batale_stratum)
      .permit(:collected_material, :collection_grades, :collection_type,
        :collection_year, :quantity, :region, :schools, :stratum_number)
  end
end
