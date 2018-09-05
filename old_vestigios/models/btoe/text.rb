class Btoe::Text
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :codigo_texto, type: String # ALFLET2013OT13-1
  field :sigla, type: String # ALFLET
  field :ano, type: Integer # 2013
  field :polo, type: String # O
  field :turma, type: Integer # 13
  field :numero_professora, type: Integer # 1
  field :texto_full, type: String # Texto completo da professora
  mount_uploader :image, ImageUploader # Campo para arquivo

  HUMANIZED_ATTRIBUTES = {
    codigo_texto: 'Código do texto',
    sigla: 'Sigla',
    ano: 'Ano',
    polo: 'Pólo',
    turma: 'Turma',
    numero_professora: 'Número da Professora',
    texto_full: 'Texto Completo'
  }.freeze

  def update_codigo_texto!
    self.codigo_texto = sigla + ano.to_s + polo + 'T' + turma.to_s + '-' + numero_professora.to_s
    save!
  end

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def self.search(params)
    if !params.empty?
      search_term_content = (params['content']&.gsub ' ', '.*')
      query = []
      query_in = {}

      # TODO: Busca não funciona direto, especialmente esse aqui em baixo
      # TODO: update: search_term não está sendo usado,
      # toda busca agora é "busca avançada"
      # search_term = params["search"].gsub " ", ".*"
      # if !search_term.empty?
      #     query << {"id_texto": /#{search_term}/i}
      # end
      # Adiciona a query os campos que não estiverem vazios
      if !search_term_content.nil? && !search_term_content.empty?
        if search_term_content.include?(';')
          query_in['texto_full'] = []
          search_term_content.split(';').each { |slice| query_in['texto_full'] << /#{slice}/i }
        else
          query << { "texto_full": /#{search_term_content}/i }
        end
      end
      if !params['numero_professora'].nil? && !params['numero_professora'].empty?
        if params['numero_professora'].include?(';')
          query_in['numero_professora'] = []
          params['numero_professora'].split(';').each { |slice| query_in['numero_professora'] << slice }
        else
          query << { "numero_professora": params['numero_professora'] }
        end
      end
      if !params['sigla'].nil? && !params['sigla'].empty?
        if params['sigla'].include?(';')
          query_in['sigla'] = []
          params['sigla'].split(';').each { |slice| query_in['sigla'] << /#{slice}/i }
        else
          query << { "sigla": /#{params["sigla"]}/i }
        end
      end
      if !params['polo'].nil? && !params['polo'].empty?
        if params['polo'].include?(';')
          query_in['polo'] = []
          params['polo'].split(';').each { |slice| query_in['polo'] << /#{slice}/i }
        else
          query << { "polo": /#{params["polo"]}/i }
        end
      end
      if !params['ano'].nil? && !params['ano'].empty?
        if params['ano'].include?(';')
          query_in['ano'] = []
          params['ano'].split(';').each { |slice| query_in['ano'] << slice }
        else
          query << { "ano": params['ano'] }
        end
      end
      if !params['turma'].nil? && !params['turma'].empty?
        if params['turma'].include?(';')
          query_in['turma'] = []
          params['turma'].split(';').each { |slice| query_in['turma'] << slice }
        else
          query << { "turma": params['turma'] }
        end
      end

      if !query.empty? && !query_in.empty?
        where(:$and => query).in(query_in).order_by(id_texto: 'asc')
      else
        if !query.empty? && query_in.empty?
          where(:$and => query).order_by(id_texto: 'asc')
        else
          if query.empty? && !query_in.empty?
            self.in(query_in).order_by(id_texto: 'asc')
          else
            all.order_by(id_texto: 'asc')
          end
        end
      end
      # self.where(:$or => [{"id_texto": /#{search_term}/i}, {"texto_full": /#{search_term}/i}]).order_by(:id_texto => 'asc')
    else
      all.order_by(id_texto: 'asc')
    end
  end

  def find_associated_colors_and_excerpts(user_id = nil)
    associated = {}
    associated[:all] = []
    associated[:user] = []
    Btoe::Color.all.each do |color|
      color.excerpts.each do |excerpt|
        next unless excerpt.text_id == id
        associated[:all] << { color: color, excerpt: excerpt }
        associated[:user] << { color: color, excerpt: excerpt } if excerpt.user_id == user_id
      end
    end
    associated
  end

  def find_associated_blocs
    associated_blocs = []
    Btoe::Bloc.all.each do |bloco|
      associated_blocs << bloco unless bloco.excerpts.where(text_id: id).empty?
    end
    associated_blocs
  end

  def colored_text_and_tags(_params = {})
    color_excerpt = { color: [], excerpt: [] }
    associated = find_associated_colors_and_excerpts[:all]
    text = texto_full
    index = {}
    trechos = []
    cores = []
    legenda = {}
    associated.each do |h|
      h.each do |k, v|
        k == :color ? (color_excerpt[k] << v.hex_color.delete('#'); legenda[v.tag] = v.hex_color.delete('#')) : color_excerpt[k] << v.trecho
      end
    end
    color_excerpt[:excerpt].each_with_index { |e, i| index[text.index(e)] = i }
    until index.empty?
      menor = text.size
      index.each { |k, _v| menor = k if k < menor }
      trechos << color_excerpt[:excerpt][index[menor]]
      cores << color_excerpt[:color][index[menor]]
      index.delete(menor)
    end
    colored_text = ''
    trechos.each_with_index do |trecho, i|
      antes, igual, text = text.partition(trecho)
      colored_text += antes + "<span style='background-color:##{cores[i]} !important'>" + igual + '</span>'
    end
    colored_text += text
    [colored_text.html_safe, legenda]
  end
end
