class Batale::Stratum
  include Mongoid::Document   # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :collected_material, type: String
  field :collection_grades,  type: String
  field :collection_type,    type: String
  field :collection_year,    type: String
  field :quantity,           type: Integer
  field :region,             type: String
  field :schools,            type: String
  field :stratum_number,     type: String

  validates :collected_material, :collection_grades, :collection_type,
    :collection_year, :quantity, :region, :schools, :stratum_number, presence: true
end
