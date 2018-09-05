class Batale::Errortog
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :name, type: String # Nome da classe de erro
  has_many :definitions, class_name: 'Batale::Definition', autosave: true # Relação 1:n com o model Batale::Definition
  recursively_embeds_many # Relação para um Errortog poder ter outros Errortogs dentro de si
  accepts_nested_attributes_for :child_errortogs, allow_destroy: true
  accepts_nested_attributes_for :definitions, allow_destroy: true

  validates :name, presence: true

  def self.find(id)
    get_all_errortogs.select { |e| e.id.to_s == id.to_s }.first || super(id)
  end

  def self.get_all_errortogs(errortogs = Batale::Errortog.all)
    all_errortogs = []
    errortogs.each do |errortog|
      all_errortogs << errortog
      all_errortogs.concat(get_all_errortogs(errortog.child_errortogs)) if errortog.child_errortogs?
    end
    all_errortogs
  end

  def parents
    @parents ||= fetch_parents
  end

  private

  def fetch_parents
    parent = parent_errortog
    parents = []
    while parent.present?
      parents << parent
      parent = parent.parent_errortog
    end
    parents.reverse
  end
end
