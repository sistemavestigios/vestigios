class Batale::Stratum
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :ano_coleta, type: String
  field :material_coletado, type: String
  field :tipo_coleta, type: String
  field :serie_ano_coleta, type: String
  field :local_coleta, type: String
  field :escola, type: String
  field :quantidade_de_textos, type: Integer
  field :numero_estrato, type: Integer

  HUMANIZED_ATTRIBUTES = {
    numero_estrato: 'Número do estrato',
    ano_coleta: 'Ano da coleta',
    material_coletado: 'Material coletado',
    tipo_coleta: 'Tipo de coleta',
    serie_ano_coleta: 'Série/Ano',
    local_coleta: 'Local da coleta',
    escola: 'Escola',
    quantidade_de_textos: 'Número de textos'
  }.freeze

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end
end
