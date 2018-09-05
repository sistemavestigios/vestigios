class Batale::Definition
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :regra, type: String # ç->ss
  field :exemplo, type: String # pessa
  field :palavra_alvo, type: String # peça
  field :errortog_name, type: String # Nome do errortog ao qual pertence
  field :errortogs_names, type: String # string com os nomes hierárquicos da categoria
  field :errortogs_ids, type: String # string com ids dos errortogs pais dessa definição
  field :color_and_initial, type: Hash
  embeds_many :words, class_name: 'Batale::Word'
  belongs_to :errortog, class_name: 'Batale::Errortog', optional: true # Relação de pertencimento com a classe Batale::Errortog
  has_and_belongs_to_many :texts, class_name: 'Batale::Text' # Relação n:n com o model Batale::Text

  def errortog
    Batale::Errortog.find(errortog_id.to_s)
  end

  def parents_ids(errortog = self.errortog)
    ids = ''
    ids += parents_ids(errortog.parent_errortog) if errortog.parent_errortog?
    ids += '_' + errortog.id.to_s
  end

  def parents_names
    if errortogs_names.nil?
      names = ''
      ids = errortogs_ids.split('_')
      ids.delete_at(0)
      ids.delete_at(ids.size - 1)
      ids.each do |id|
        names += Batale::Errortog.find(id).name
        names += ' -> '
      end
      self.errortogs_names = names += errortog_name
      save!
    end
    errortogs_names
  end

  def get_color_and_initial
    if color_and_initial.nil?
      color_and_initial = {}
      nome_base = Batale::Errortog.find(errortogs_ids.split('_')[1]).name
      color_and_initial[:color] = nome_base == 'Fonológico' ? 'blue' : nome_base == 'Ortográfico' ? 'purple' : 'green'
      color_and_initial[:initial] = nome_base == 'Fonológico' ? 'F' : nome_base == 'Ortográfico' ? 'O' : 'FG'
      self.color_and_initial = color_and_initial
      save!
    end
    self.color_and_initial
  end

  def tags_ids(text_id)
    ids = []
    words.each { |w| ids << w.tag_id if w.text_id == text_id }
    ids.uniq
  end

  def filtered_words(text_id)
    words.where('text_id' => text_id)
  end

  private

  def self.search(params)
    query = []
    query << { "regra": /#{params["regra"]}/i } unless params['regra'].empty?
    query << { "words.right": /#{params["palavra_alvo"]}/i } unless params['palavra_alvo'].empty?
    query << { "errortog": Batale::Errortog.find(nil, params['errortog']) } unless params['errortog'].empty?
    unless params['0'].empty?
      unless params['1'].empty?
        unless params['2'].empty?
          unless params['3'].empty?
            return Batale::Errortog.find(params['4'], nil).get_definitions unless params['4'].empty?
            return Batale::Errortog.find(params['3'], nil).get_definitions
          end
          return Batale::Errortog.find(params['2'], nil).get_definitions
        end
        return Batale::Errortog.find(params['1'], nil).get_definitions
      end
      return Batale::Errortog.find(params['0'], nil).get_definitions
    end
    where(:$and => query).order_by(regra: 'asc') unless query.empty?
  end
end
