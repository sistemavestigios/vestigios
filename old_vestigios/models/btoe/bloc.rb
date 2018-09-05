class Btoe::Bloc
  include Mongoid::Document
  include Mongoid::Timestamps

  field :nome, type: String
  field :descricao, type: String
  field :private, type: Boolean
  embeds_many :excerpts
  embeds_many :comments, class_name: 'Btoe::Comment'
  # has_many :comments, class_name: "Btoe::Comment"
  belongs_to :user

  HUMANIZED_ATTRIBUTES = {
    nome: 'Nome do Bloco',
    descricao: 'Descrição do Bloco'
  }.freeze

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def self.search(params)
    query = []
    if params[:search]
      search_term = params[:search].gsub ' ', '.*'
      query << { "nome": /#{search_term}/i } unless search_term.empty?
    end

    if query.empty?
      all.order_by(nome: 'asc')
    else
      where(:$or => query).order_by(nome: 'asc')
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
    unless bloc_params(params).empty?
      excerpts = []
      self.excerpts.each do |e|
        text = Btoe::Text.find(e.text_id)
        excerpts << e if add_text_excerpt?(text, excerpt, params)
      end
    end
    excerpts
  end

  def bloc_params(params)
    @bloc_params ||= begin
      params.delete_if { |k| !params[k].present? }
      %w[sigla ano polo turma numero_professora content] & params.keys
    end
  end

  def add_text_excerpt?(text, excerpt, params)
    add = true
    @bloc_params.each do |param|
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
