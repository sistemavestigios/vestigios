class Btp::Comment
  include Mongoid::Document   # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :comment, type: String # Comentário do bloco
  field :user_id, type: BSON::ObjectId

  embedded_in :commentable, polymorphic: true # Pode ser embedded em mais de uma classe

  recursively_embeds_many # Para um comentário ter comentários
  accepts_nested_attributes_for :child_comments, allow_destroy: true

  validates :comment, :user_id, presence: true

  def self.permitted_attributes
    %i[id comment user_id _destroy] + [child_comments_attributes: %i[id comment user_id _destroy]]
  end

  def user
    @user ||= User.find(user_id)
  end
end
