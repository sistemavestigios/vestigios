class Btp::Excerpt
  include Mongoid::Document   # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :excerpt, type: String         # Trecho do texto a ser associado a um bloco ou uma cor
  field :text_id, type: BSON::ObjectId # _id do texto a qual o trecho pertence
  field :user_id, type: BSON::ObjectId # _id do usuario que criou o excerpt

  embeds_many :comments, class_name: 'Btp::Comment', as: :commentable, cascade_callbacks: true

  embedded_in :excerptable, polymorphic: true # Pode ser embedded em mais de uma classe

  accepts_nested_attributes_for :comments, allow_destroy: true

  validates :excerpt, :text_id, :user_id, presence: true

  before_create :set_parent_id_on_text, :set_text_id_on_parent
  before_destroy :remove_parent_id_on_text, :remove_text_id_on_parent

  def self.permitted_attributes
    %i[id excerpt text_id user_id _destroy] + [comments_attributes: Btp::Comment.permitted_attributes]
  end

  def user
    @user ||= User.find(user_id)
  end

  def text
    @text ||= excerptable.texts.find(text_id)
  end

  private

  def remove_parent_id_on_text
    btp_text = Btp::Text.find(text_id)
    btp_text.bloc_ids.delete(excerptable.id)
    btp_text.color_ids.delete(excerptable.id)
  end

  def remove_text_id_on_parent
    excerptable.text_ids.delete(text_id)
  end

  def set_parent_id_on_text
    btp_text = Btp::Text.find(text_id)
    case excerptable.class
    when Btp::Bloc
      btp_text.bloc_ids |= [excerptable.id]
    when Btp::Color
      btp_text.color_ids |= [excerptable.id]
    else
      raise 'Error on set_parent_id_on_text'
    end
  end

  def set_text_id_on_parent
    excerptable.text_ids |= [text_id]
  end
end
