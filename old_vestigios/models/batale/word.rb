class Batale::Word
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :wrong, type: String
  field :right, type: String
  field :tag_id, type: String
  field :text_id, type: BSON::ObjectId

  embedded_in :definition, class_name: 'Batale::Definition'
end
