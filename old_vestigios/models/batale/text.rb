class Batale::Text
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :codigo_texto, type: String # 0001_071000_M_01_01_01_2001_TN_BA_1S_B
  field :nome_aluno, type: String # Campo para o nome do aluno autor do texto
  field :numero_aluno, type: String # 0001 número único do aluno
  field :idade, type: String # 071000 idade do aluno (7 anos, 10 meses, 0 dias)
  field :sexo, type: String # M/F Sexo do aluno
  field :numero_estrato, type: Integer # 01 número do estrato a que pertence o texto do aluno
  field :numero_coleta, type: Integer # 01 número da coleta a que pertence o texto do aluno
  field :numero_texto, type: Integer # 01 número do texto do aluno (para quando houver mais de um texto na mesma coleta)
  field :ano_coleta, type: Integer # 2001 ano em que foi feita a coleta do texto do aluno
  field :tipo_texto, type: String # TN tipo de texto (Texto Narrativo) produzido pelo aluno
  field :escola_crianca, type: String # BA escola (Bibiano de Almeida) do aluno
  field :serie, type: String # 1S  série/ano do aluno
  field :turma, type: String # B turma do aluno
  field :texto_original, type: String # Texto original do aluno, conforme ele escreveu
  field :texto_normatizado, type: String # Texto do aluno pós correção, pré correção usando hunspell + eventual correção dos usuários
  field :texto_highlighted, type: String # Texto original com as palavras erradas highlighted
  field :tipo_escrita, type: String # Desenho, escrita alfabética/pré alfabética
  has_and_belongs_to_many :definitions, class_name: 'Batale::Definition' # Relação n:n com o model Batale::Definition
  mount_uploader :image, ImageUploader # Campo para arquivo

  HUMANIZED_ATTRIBUTES = {
    codigo_texto: 'Código do texto',
    nome_aluno: 'Nome do aluno',
    numero_aluno: 'Número do aluno',
    idade: 'Idade do aluno',
    sexo: 'Sexo do aluno',
    numero_estrato: 'Número do estrato',
    numero_coleta: 'Número da coleta',
    numero_texto: 'Número do texto do aluno',
    ano_coleta: 'Ano da coleta do texto',
    tipo_texto: 'Tipo de texto',
    escola_crianca: 'Escola do aluno',
    serie: 'Série do aluno',
    turma: 'Turma do aluno',
    texto_original: 'Texto original',
    texto_normatizado: 'Texto Normatizado'
  }.freeze

  def def_ids
    ids = []
    definition_ids.each do |id|
      ids << id.to_s
    end
    ids
  end

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def cria_codigo_texto
    # TODO: ver como o codigo é feito de fato
    self.codigo_texto = numero_aluno + '_' + idade + '_' + sexo + '_' + numero_estrato.to_s + '_' + numero_coleta.to_s + '_' + numero_texto.to_s + '_' + escola_crianca + '_' + serie
  end

  # Para a busca
  # Copiei direto do que ja existia antes, que o Pedro tinha feito
  # update:
  # nao sei pq ele mandava pra ca um [index_params] ao inves de index_params direto,
  # ai ele tinha que usar params[0]['campo'] sempre
  def self.search(params)
    if !params.empty?
      nome_aluno = !params['name_student'].nil? ? params['name_student'].gsub(' ', '.*') : ''
      search_term_content = !params['search_content'].nil? ? params['search_content'].gsub(' ', '.*') : ''
      query = []
      query_in = {}

      # Adiciona a query os campos que não estiverem vazios
      unless search_term_content.empty?
        if search_term_content.include?(';')
          query_in['texto_normatizado'] = []
          search_term_content.split(';').each { |slice| query_in['texto_normatizado'] << /#{slice}/i }
        else
          query << { "texto_normatizado": /#{search_term_content}/i }
        end
      end
      unless nome_aluno.empty?
        if nome_aluno.include?(';')
          query_in['nome_aluno'] = []
          nome_aluno.split(';').each { |slice| query_in['nome_aluno'] << /#{slice}/i }
        else
          query << { "nome_aluno": /#{nome_aluno}/i }
        end
      end
      if !params['number_student'].nil? && !params['number_student'].empty?
        if params['number_student'].include?(';')
          query_in['numero_aluno'] = []
          params['number_student'].split(';').each do |slice|
            slice = slice.size < 4 ? '0' * (4 - slice.size) + slice : slice
            query_in['numero_aluno'] << slice
          end
        else
          slice = params['number_student']
          slice = slice.size < 4 ? '0' * (4 - slice.size) + slice : slice
          query << { "numero_aluno": slice }
        end
      end
      if !params['age'].nil? && !params['age'].empty?
        if params['age'].include?(';')
          query_in['idade'] = []
          params['age'].split(';').each { |slice| query_in['idade'] << slice }
        else
          query << { "idade": params['age'] }
        end
      end
      if !params['gender'].nil? && !params['gender'].empty?
        if params['gender'].include?(';')
          query_in['sexo'] = []
          params['gender'].split(';').each { |slice| query_in['sexo'] << /#{slice}/i }
        else
          query << { "sexo": /#{params["gender"]}/i }
        end
      end
      if !params['stratum'].nil? && !params['stratum'].empty?
        if params['stratum'].include?(';')
          query_in['numero_estrato'] = []
          params['stratum'].split(';').each { |slice| query_in['numero_estrato'] << slice }
        else
          query << { "numero_estrato": params['stratum'] }
        end
      end
      if !params['numero_estrato'].nil? && !params['numero_estrato'].empty?
        if params['numero_estrato'].include?(';')
          query_in['numero_estrato'] = []
          params['numero_estrato'].split(';').each { |slice| query_in['numero_estrato'] << slice }
        else
          query << { "numero_estrato": params['numero_estrato'] }
        end
      end
      if !params['collection'].nil? && !params['collection'].empty?
        if params['collection'].include?(';')
          query_in['numero_coleta'] = []
          params['collection'].split(';').each { |slice| query_in['numero_coleta'] << slice }
        else
          query << { "numero_coleta": params['collection'] }
        end
      end
      if !params['number_text'].nil? && !params['number_text'].empty?
        if params['number_text'].include?(';')
          query_in['numero_texto'] = []
          params['number_text'].split(';').each { |slice| query_in['numero_texto'] << slice }
        else
          query << { "numero_texto": params['number_text'] }
        end
      end
      if !params['year'].nil? && !params['year'].empty?
        if params['year'].include?(';')
          query_in['ano_coleta'] = []
          params['year'].split(';').each { |slice| query_in['ano_coleta'] << slice }
        else
          query << { "ano_coleta": params['year'] }
        end
      end
      if !params['type'].nil? && !params['type'].empty?
        if params['type'].include?(';')
          query_in['tipo_texto'] = []
          params['type'].split(';').each { |slice| query_in['tipo_texto'] << /#{slice}/i }
        else
          query << { "tipo_texto": /#{params["type"]}/i }
        end
      end
      if !params['school'].nil? && !params['school'].empty?
        if params['school'].include?(';')
          query_in['escola_crianca'] = []
          params['school'].split(';').each { |slice| query_in['escola_crianca'] << /#{slice}/i }
        else
          query << { "escola_crianca": /#{params["school"]}/i }
        end
      end
      if !params['class'].nil? && !params['class'].empty?
        if params['class'].include?(';')
          query_in['turma'] = []
          params['class'].split(';').each { |slice| query_in['turma'] << /#{slice}/i }
        else
          query << { "turma": /#{params["class"]}/i }
        end
      end
      if !params['school_grade'].nil? && !params['school_grade'].empty?
        if params['school_grade'].include?(';')
          query_in['serie'] = []
          params['school_grade'].split(';').each { |slice| query_in['serie'] << /#{slice}/i }
        else
          query << { "serie": /#{params["school_grade"]}/i }
        end
      end

      if !query.empty? && !query_in.empty?
        where(:$and => query).in(query_in).order_by(nome_aluno: 'asc')
      else
        if !query.empty? && query_in.empty?
          where(:$and => query).order_by(nome_aluno: 'asc')
        else
          if query.empty? && !query_in.empty?
            self.in(query_in).order_by(nome_aluno: 'asc')
          else
            all.order_by(nome_aluno: 'asc')
          end
        end
      end

    else
      all.order_by(nome_aluno: 'asc')
    end
  end

  def texto_original_highlighted
    if texto_highlighted.nil?
      t_o_high = texto_original
      final = ''
      index = 0
      while t_o_high != ''
        before, br, t_o_high = t_o_high.partition(/\n/)
        if before != ''
          count = before.partition(/\w/)[0].count(' ')
          final += ' ' * count if count > 0
          while before != ''
            _, word, before = before.partition(/[\dªºa-zãâáêéíõôóúA-ZÃÂÁÊẼÍÕÔÓÚ_-]+\s*/)
            final += '<b id="word_index_' + index.to_s + '">' + word + '</b>' if word != ''
            index += 1 if word != ''
          end
          final += '<br>'
        elsif br != ''
          final += '<br>'
        end
      end
      self.texto_highlighted = final
    end
    texto_highlighted.html_safe
  end
end
