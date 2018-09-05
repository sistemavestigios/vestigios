class Batale::Errortog
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :name, type: String # Nome da classe de erro
  has_many :definitions, class_name: 'Batale::Definition' # Relação 1:n com o model Batale::Definition
  recursively_embeds_many # Relação para um Errortog poder ter outros Errortogs dentro de si {name: = 'exemplo', definitions: [], errortogs: [{name:'filho1', definitions: [], errortogs: []}, {name:'filho2', definitions: [], errortogs: []}] }

  HUMANIZED_ATTRIBUTES = { name: 'Nome', definitions: 'Exemplos' }.freeze

  def get_definitions
    definitions = []
    child_errortogs.each { |child| definitions.concat(child.get_definitions) } if child_errortogs?
    self.definitions.each { |defn| definitions << defn } if definitions?
    definitions
  end

  private

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def self.get_all_errortogs(errortogs = Batale::Errortog.all)
    all_errortogs = []
    errortogs.each do |err|
      all_errortogs << err
      all_errortogs.concat(get_all_errortogs(err.child_errortogs)) if err.child_errortogs?
    end
    all_errortogs
  end

  def self.get_next_depth(errortogs)
    next_depth = []
    errortogs.each do |err|
      next_depth.concat(err.child_errortogs) if err.child_errortogs?
    end
    next_depth
  end

  def self.find(id = nil, name = nil)
    errortogs = Batale::Errortog.get_all_errortogs
    err_return = nil
    errortogs.each do |err|
      err_return = err if err._id.to_s == id
    end
    unless name.nil?
      errortogs.each do |err|
        err_return = err if err.name == name
      end
    end
    err_return
  end
end
