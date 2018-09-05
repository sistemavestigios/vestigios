class Btp::Text
  include Mongoid::Document   # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :code,           type: String  # ALFLET2013OT13-1
  field :acronym,        type: String  # ALFLET
  field :year,           type: String # 2013
  field :region,         type: String # O
  field :class_number,   type: String # 13
  field :teacher_number, type: String # 1
  field :full,           type: String # Texto completo da professora

  has_and_belongs_to_many :blocs,  class_name: 'Btp::Bloc'
  has_and_belongs_to_many :colors, class_name: 'Btp::Color'

  validates :year, :code, :teacher_number, :region, :full, :class_number, :acronym, presence: true

  before_validation :create_code, on: %i[create update]

  IGNORED_FIELD_NAMES = %w[
    _id
    bloc_ids
    color_ids
    created_at
    full
    updated_at
  ].freeze

  def self.field_names
    @field_names ||= fields.keys.delete_if { |k| IGNORED_FIELD_NAMES.include?(k) }
  end

  def self.only_show_texts_from_acronym?(search_params)
    search_params.key?(:acronym) && search_params[:acronym].size == 1 && search_params.keys.size == 1
  end

  def self.options(attribute)
    pluck(attribute).uniq.sort
  end

  def self.search(params)
    params = ActionController::Parameters.new params if params.is_a?(Hash)
    search_params = params.permit(field_names.collect { |fn| { fn => [] } }, :acronym, :full)
    search_params.delete_if { |_k, v| v.empty? }
    search_params[:full] = search_params[:full].split(';').collect { |word| /#{word}/i } if search_params.key?(:full)
    return Btp::Text.none if search_params.empty?
    return where(acronym: search_params[:acronym].first) if only_show_texts_from_acronym?(search_params)
    self.in(search_params)
  end

  def self.thematics
    @thematics ||= all.group_by(&:acronym).map { |a, t| { acronym: a, count: t.count } }.sort_by { |a| a[:acronym] }
  end

  def rows
    new_record? ? 5 : full.split("\n").count
  end

  private

  def create_code
    self.code = "#{acronym.try(:upcase)}#{year}#{region.try(:upcase)}T#{class_number}-#{teacher_number}"
  end
end
