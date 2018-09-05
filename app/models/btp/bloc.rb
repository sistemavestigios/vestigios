class Btp::Bloc
  include Mongoid::Document   # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :description, type: String
  field :name,        type: String
  field :secret,      type: Boolean, default: false

  embeds_many :comments, class_name: 'Btp::Comment', as: :commentable, cascade_callbacks: true
  embeds_many :excerpts, class_name: 'Btp::Excerpt', as: :excerptable, cascade_callbacks: true

  accepts_nested_attributes_for :comments, allow_destroy: true
  accepts_nested_attributes_for :excerpts, allow_destroy: true

  belongs_to :user
  has_and_belongs_to_many :texts, class_name: 'Btp::Text'

  validates :name, :secret, presence: true
end
