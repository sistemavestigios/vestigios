class Batale::Word
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :wrong, type: String
  field :right, type: String
  field :text_id, type: BSON::ObjectId

  embedded_in :definition, class_name: 'Batale::Definition'

  validates :wrong, :right, :text_id, presence: true

  before_create :set_definition_id_on_text, :set_text_id_on_definition
  before_destroy :remove_definition_id_on_text, :remove_text_id_on_definition

  def self.permitted_attributes
    %i[id wrong right text_id _destroy]
  end

  def text
    Batale::Text.find(text_id)
  end

  private

  def set_definition_id_on_text
    batale_text = Batale::Text.find(text_id)
    batale_text.update_attributes!(definition_ids: batale_text.definitions | [definition.id])
  end

  def set_text_id_on_definition
    definition.text_ids |= [text_id]
  end

  def remove_definition_id_on_text
    batale_text = Batale::Text.find(text_id)
    batale_text.update_attributes!(definition_ids: batale_text.definitions.map(&:id) - [definition.id])
  end

  def remove_text_id_on_definition
    definition.text_ids.delete(text_id)
  end
end
