class Btoe::Color
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento
  resourcify :resources

  field :hex_color, type: String # Cor em hexademacimal #8BC34A
  field :tag, type: String # Legenda da cor, exemplo: 'Letramento'
  belongs_to :user
  embeds_many :comments, class_name: 'Btoe::Comment'
  embeds_many :excerpts

  validates :tag, presence: { message: 'Tag da cor não pode estar vazia' },
                  length: { minimum: 3, message: 'Tag muito pequena. Coloque 3 ou mais caracteres' }

  validates :hex_color, presence: { message: 'Cor não definida' },
                        length: { minimum: 7, maximum: 7, message: 'Cor mal definida' }

  HUMANIZED_ATTRIBUTES = {
    hex_color: 'Cor (em hexadecimal)',
    tag: 'Nome associado à cor',
    user_id: 'Usuário que criou'
  }.freeze

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def used_in_many_trechos
    # TODO: melhor jeito de fazer?
    excerpts.count
  end

  def used_in_many_texts
    # TODO: melhor jeito de fazer?
    texts = []
    excerpts.each do |e|
      texts << e.text_id
    end
    texts.uniq!
    texts.count
  end

  # def created_by
  #   self.user.full_name
  # end

  def text_color
    # http://stackoverflow.com/questions/12043187/how-to-check-if-hex-color-is-too-black
    # se a luminancia for muito alta, por aquela formula ali,
    # seria bom trocar a cor do texto do titulo pra preto

    r = hex_color.slice(1, 2).to_i(16)
    g = hex_color.slice(3, 2).to_i(16)
    b = hex_color.slice(5, 2).to_i(16)

    luma = 0.2126 * r + 0.7152 * g + 0.0722 * b; # // per ITU-R BT.709
    if luma > 131
      '#000'
    else
      '#fff'
    end
  end

  def self.search(params)
    query = []
    query_in = {}

    if !params['color_tag'].nil? && !params['color_tag'].empty?
      color_tag = params['color_tag'].gsub ' ', '.*'
      if color_tag.include?(';')
        query_in['tag'] = []
        color_tag.split(';').each { |slice| query_in['tag'] << /#{slice}/i }
      else
        query << { "tag": /#{color_tag}/i } unless color_tag.empty?
      end

    end

    if !query.empty? && !query_in.empty?
      where(:$or => query).in(query_in).order_by(tag: 'asc')
    elsif !query.empty? && query_in.empty?
      where(:$or => query).order_by(tag: 'asc')
    elsif query.empty? && !query_in.empty?
      self.in(query_in).order_by(tag: 'asc')
    else
      all
    end
  end

  def has_excerpt_comments?
    has = false
    if excerpts?
      excerpts.each do |excerpt|
        has = true if excerpt.comments?
      end
    end
    has
  end

  def has_comment_comments?
    has = false
    comments.each do |comment|
      has = true if comment.child_comments?
    end
    has
  end

  def filtered_excerpts(params)
    excerpts = self.excerpts
    unless color_params(params).empty?
      excerpts = []
      self.excerpts.each do |e|
        text = Btoe::Text.find(e.text_id)
        excerpts << e if add_text_excerpt?(text, e, params)
      end
    end
    excerpts
  end

  def color_params(params)
    @color_params ||= begin
      params.delete_if { |k| !params[k].present? }
      %w[sigla ano polo turma numero_professora content] & params.keys
    end
  end

  def add_text_excerpt?(text, excerpt, params)
    add = true
    @color_params.each do |param|
      add &= case param
             when 'content'
               excerpt.trecho.index(/#{params[param]}/i).present?
             else
               text[param].to_s.casecmp(params[param]).zero?
             end
      break unless add
    end
  end
end
