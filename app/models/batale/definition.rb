class Batale::Definition
  include Mongoid::Document   # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :example, type: String     # pessa
  field :rule, type: String        # ç->ss
  field :target_word, type: String # peça

  # Relação de pertencimento com a classe Batale::Errortog
  belongs_to :errortog, class_name: 'Batale::Errortog', optional: true
  # Relação de n:n com a classe Batale::Text
  has_and_belongs_to_many :texts, class_name: 'Batale::Text'
  embeds_many :words, class_name: 'Batale::Word', cascade_callbacks: true

  accepts_nested_attributes_for :words, allow_destroy: true

  validates :example, :target_word, :rule, presence: true

  def self.permitted_attributes
    %i[id example target_word rule _destroy]
  end

  def self.search(params)
    search_params = params.permit('words.right', name: [], rule: [])
    search_params.delete_if { |_k, v| v.empty? }
    search_params['words.right'] = search_params['words.right'].split(';').collect { |w| /#{w}/i } if search_params.key?('words.right')
    return Batale::Definition.none if search_params.empty?
    self.in(search_params)
  end

  def errortog
    @errortog ||= Batale::Errortog.find(errortog_id)
  end

  def options(attribute)
    return texts.pluck(:student_number).uniq.sort_by(&:to_i) if attribute == :student_number
    texts.pluck(attribute).compact.uniq.sort
  end

  def correct_words_for_text(text_id)
    words.select { |w| w.text_id == text_id }.map(&:right)
  end

  def wrong_words_for_text(text_id)
    words.select { |w| w.text_id == text_id }.map(&:wrong)
  end

  def search_associated_texts(params)
    search_params = params.permit(Batale::Text.field_names.collect { |fn| { fn => [] } })
    texts.in(search_params)
  end
end
