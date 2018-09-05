class Btoe::Comment
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :comment, type: String # Comentário do bloco
  field :user_id, type: BSON::ObjectId
  embedded_in :bloc, class_name: 'Btoe::Bloc', polymorphic: true
  embedded_in :color, class_name: 'Btoe::Color', polymorphic: true
  embedded_in :excerpt, polymorphic: true
  recursively_embeds_many # Para um comentário ter comentários

  def user
    User.find(user_id)
  end
end
