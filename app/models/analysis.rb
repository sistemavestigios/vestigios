class Analysis
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  field :label, type: String # algum nome dado
  field :favorite, type: Boolean, default: false # se foi favoritada
  field :type_analyzed, type: String # tipo => texts, colors, blocs
  field :ids_analyzed, type: Array # id de todos objetos analisados
  field :params_queried, type: Hash # busca que gerou esta análise

  belongs_to :user

  validates :type_analyzed, :ids_analyzed, :params_queried, presence: true

  STOP_WORDS =
    [
      'n', 'de', 'a', 'o', 'que', 'e', 'do', 'da', 'em', 'um', 'para', 'é', 'com', 'não',
      'uma', 'os', 'no', 'se', 'na', 'por', 'mais', 'as', 'dos', 'como', 'mas', 'foi', 'ao',
      'ele', 'das', 'tem', 'à', 'seu', 'sua', 'ou', 'ser', 'quando', 'muito', 'há', 'nos',
      'já', 'está', 'eu', 'também', 'só', 'pelo', 'pela', 'até', 'isso', 'ela', 'entre',
      'era', 'depois', 'sem', 'mesmo', 'aos', 'ter', 'seus', 'quem', 'nas', 'me', 'esse',
      'eles', 'estão', 'você', 'tinha', 'foram', 'essa', 'num', 'nem', 'suas', 'meu', 'às',
      'minha', 'têm', 'numa', 'pelos', 'elas', 'havia', 'seja', 'qual', 'será', 'nós',
      'tenho', 'lhe', 'deles', 'essas', 'esses', 'pelas', 'este', 'fosse', 'dele', 'tu',
      'te', 'vocês', 'vos', 'lhes', 'meus', 'minhas', 'teu', 'tua', 'teus', 'tuas',
      'nosso', 'nossa', 'nossos', 'nossas', 'dela', 'delas', 'esta', 'estes', 'estas',
      'aquele', 'aquela', 'aqueles', 'aquelas', 'isto', 'aquilo', 'estou', 'está',
      'estamos', 'estão', 'estive', 'esteve', 'estivemos', 'estiveram', 'estava',
      'estávamos', 'estavam', 'estivera', 'estivéramos', 'esteja', 'estejamos',
      'estejam', 'estivesse', 'estivéssemos', 'estivessem', 'estiver', 'estivermos',
      'estiverem', 'hei', 'há', 'havemos', 'hão', 'houve', 'houvemos', 'houveram',
      'houvera', 'houvéramos', 'haja', 'hajamos', 'hajam', 'houvesse', 'houvéssemos',
      'houvessem', 'houver', 'houvermos', 'houverem', 'houverei', 'houverá',
      'houveremos', 'houverão', 'houveria', 'houveríamos', 'houveriam', 'sou',
      'somos', 'são', 'era', 'éramos', 'eram', 'fui', 'foi', 'fomos', 'foram', 'fora',
      'fôramos', 'seja', 'sejamos', 'sejam', 'fosse', 'fôssemos', 'fossem', 'for',
      'formos', 'forem', 'serei', 'será', 'seremos', 'serão', 'seria', 'seríamos',
      'seriam', 'tenho', 'tem', 'temos', 'tém', 'tinha', 'tínhamos', 'tinham', 'tive',
      'teve', 'tivemos', 'tiveram', 'tivera', 'tivéramos', 'tenha', 'tenhamos',
      'tenham', 'tivesse', 'tivéssemos', 'tivessem', 'tiver', 'tivermos', 'tiverem',
      'terei', 'terá', 'teremos', 'terão', 'teria', 'teríamos', 'teriam', '-'
    ].freeze

  def self.from_batale_texts(user_id, search_params)
    text_ids = Batale::Text.search(search_params).pluck(:id)
    create_with(user_id: user_id, label: '', type_analyzed: 'Batale::Text', params_queried: search_params)
      .find_or_create_by(ids_analyzed: text_ids)
  end

  def self.from_btp_texts(user_id, search_params)
    text_ids = Btp::Text.search(search_params).pluck(:id)
    create_with(user_id: user_id, label: '', type_analyzed: 'Btp::Text', params_queried: search_params)
      .find_or_create_by(ids_analyzed: text_ids)
  end

  def self.from_blocs(user_id, search_params)
    bloc_ids = Btp::Bloc.search(search_params).pluck(:id)
    create_with(user_id: user_id, label: '', type_analyzed: 'Btp::Bloc', params_queried: search_params)
      .find_or_create_by(ids_analyzed: bloc_ids)
  end

  def self.from_colors(user_id, search_params)
    color_ids = Btp::Color.search(search_params).pluck(:id)
    create_with(user_id: user_id, label: '', type_analyzed: 'Btp::Color', params_queried: search_params)
      .find_or_create_by(ids_analyzed: color_ids)
  end

  def self.stop_words
    @stop_words ||= STOP_WORDS
  end

  def type
    case type_analyzed
    when 'Btoe::Text' then ActionController::Base.helpers.pluralize(ids_analyzed.count, 'texto', 'textos')
    when 'Btoe::Bloc' then ActionController::Base.helpers.pluralize(ids_analyzed.count, 'bloco', 'blocos')
    when 'Btoe::Color' then ActionController::Base.helpers.pluralize(ids_analyzed.count, 'cor', 'cores')
    else ''
    end
  end
end
