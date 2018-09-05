class Batale::Bloc
  include Mongoid::Document
  include Mongoid::Timestamps

  field :nome, type: String
  field :descricao, type: String
  embeds_many :excerpts

  HUMANIZED_ATTRIBUTES = {
    nome: 'Nome do Bloco',
    descricao: 'Descrição do Bloco'
  }.freeze

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def self.search(params)
    query = []
    if params[:search]
      search_term = params[:search].gsub ' ', '.*'
      query << { "nome": /#{search_term}/i } unless search_term.empty?
    end

    if params[:content]
      search_term_content = params[:content].gsub ' ', '.*'
      query << { "descricao": /#{search_term_content}/i } unless search_term_content.empty?
    end

    if query.empty?
      all.order_by(nome: 'asc')
    else
      where(:$or => query).order_by(nome: 'asc')
    end
  end
end
