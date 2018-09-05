class Batale::Text
  include Mongoid::Document   # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :code,                type: String  # 0001_071000_M_01_01_01_2001_TN_BA_1S_B
  field :student_name,        type: String  # Campo para o nome do aluno autor do texto
  field :student_number,      type: String  # 0001 número único do aluno
  field :student_age,         type: String  # 071000 idade do aluno (7 anos, 10 meses, 0 dias)
  field :student_sex,         type: String  # M/F Sexo do aluno
  field :stratum_number,      type: String  # 01 número do estrato a que pertence o texto do aluno
  field :collection_number,   type: String  # 01 número da coleta a que pertence o texto do aluno
  field :student_text_number, type: String  # 01 número do texto do aluno
  field :collection_year,     type: String  # 2001 ano em que foi feita a coleta do texto do aluno
  field :type,                type: String  # TN tipo de texto (Texto Narrativo) produzido pelo aluno
  field :student_school,      type: String  # BA escola (Bibiano de Almeida) do aluno
  field :student_grade,       type: String  # 1S série/ano do aluno
  field :student_class,       type: String  # B turma do aluno
  field :original,            type: String  # Texto original do aluno, conforme ele escreveu
  field :normalized,          type: String  # Texto do aluno pós correção
  field :highlighted,         type: String  # Texto original com as palavras erradas highlighted
  field :writing_type,        type: String  # Desenho, escrita alfabética/pré alfabética

  # Relação de n:n com a classe Batale::Definition
  has_and_belongs_to_many :definitions, class_name: 'Batale::Definition'

  validates :code, :student_number, :student_age, :student_sex,
    :stratum_number, :collection_number, :student_text_number, :collection_year,
    :type, :student_school, :student_grade, :student_class, :original, presence: true

  validates :code, uniqueness: true

  before_validation :create_code, on: %i[create update]

  IGNORED_FIELD_NAMES = %w[
    _id
    code
    created_at
    definition_ids
    highlighted
    normalized
    original
    updated_at
  ].freeze

  def self.field_names
    @field_names ||= fields.keys.delete_if { |k| IGNORED_FIELD_NAMES.include?(k) }
  end

  def self.only_show_texts_from_stratum_number?(search_params)
    search_params.key?(:stratum_number) && search_params[:stratum_number].size == 1 && search_params.keys.size == 1
  end

  def self.options(attribute)
    return pluck(:student_number).uniq.sort_by(&:to_i) if attribute == :student_number
    return ['M', 'F'] if attribute == :student_sex
    pluck(attribute).compact.uniq.sort
  end

  def self.search(params)
    params = ActionController::Parameters.new params if params.is_a?(Hash)
    search_params = params.permit(field_names.collect { |fn| { fn => [] } }, :normalized, :original, :stratum_number)
    search_params.delete_if { |_k, v| v.empty? }
    search_params[:normalized] = search_params[:normalized].split(';').collect { |word| /#{word}/i } if search_params.key?(:normalized)
    search_params[:original] = search_params[:original].split(';').collect { |word| /#{word}/i } if search_params.key?(:original)
    return Batale::Text.none if search_params.empty?
    return where(stratum_number: search_params[:stratum_number].first) if only_show_texts_from_stratum_number?(search_params)
    search_params[:normalized] = /#{search_params[:normalized]}/i if search_params.key?(:normalized)
    self.in(search_params)
  end

  def self.strata_info
    Batale::Text.all.group_by(&:stratum_number)
                .map { |sn, t| { stratum_number: sn, count: t.count } }
                .sort_by { |s| s[:stratum_number] }
  end

  def original_highlighted
    highlighted ||= begin
      t_original = original
      final = ''
      index = 0
      while t_original != ''
        before, br, t_original = t_original.partition(/\n/)
        if before != ''
          count = before.partition(/\w/)[0].count(' ')
          final += ' ' * count if count.positive?
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
      size = final.length
      final[0..size - 5]
    end
    self.highlighted = highlighted
    save
    highlighted.html_safe
  end

  def rows
    new_record? ? 5 : original.split("\n").count
  end

  private

  def create_code
    self.code = "#{student_number}_#{student_age}_#{student_sex}_#{stratum_number}_#{collection_number}_" \
                "#{student_text_number}_#{collection_year}_#{type}_#{student_school}_#{student_grade}_#{student_class}"
  end
end
