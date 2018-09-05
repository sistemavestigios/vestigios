class Excerpt
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :trecho, type: String # Trecho do texto a ser associado a um bloco ou uma cor
  field :text_id, type: BSON::ObjectId # _id do texto a qual o trecho pertence
  field :user_id, type: BSON::ObjectId # _id do usuario que criou o excerpt
  embeds_many :comments, class_name: 'Btoe::Comment'

  embedded_in :color, class_name: 'Btoe::Color', polymorphic: true
  embedded_in :bloc, class_name: 'Btoe::Bloc', polymorphic: true
  embedded_in :bloc, class_name: 'Batale::Bloc', polymorphic: true

  def get_codigo_texto
    parent_class = _parent.class.to_s.split('::')[0]
    codigo_texto = parent_class == 'Btoe' ?
    Btoe::Text.find(text_id).codigo_texto
    : Batale::Text.find(text_id).codigo_texto
  end
end
