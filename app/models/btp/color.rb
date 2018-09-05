class Btp::Color
  include Mongoid::Document   # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :hex_color, type: String # Cor em hexademacimal #8BC34A
  field :tag, type: String       # Legenda da cor, exemplo: 'Letramento'

  embeds_many :comments, class_name: 'Btp::Comment', as: :commentable, cascade_callbacks: true
  embeds_many :excerpts, class_name: 'Btp::Excerpt', as: :excerptable, cascade_callbacks: true

  accepts_nested_attributes_for :comments, allow_destroy: true
  accepts_nested_attributes_for :excerpts, allow_destroy: true

  belongs_to :user
  has_and_belongs_to_many :texts, class_name: 'Btp::Text'

  validates :hex_color, :tag, presence: true

  def text_color
    r = hex_color.slice(1, 2).to_i(16)
    g = hex_color.slice(3, 2).to_i(16)
    b = hex_color.slice(5, 2).to_i(16)

    luma = 0.2126 * r + 0.7152 * g + 0.0722 * b; # // per ITU-R BT.709
    luma > 131 ? '#000' : '#fff'
  end
end
