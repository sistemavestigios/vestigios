class Role
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento

  ROLES = %w[admin batale btp].freeze

  field :name, type: String

  has_many :users

  validates :name, presence: true, uniqueness: true, inclusion: { in: ROLES }

  def self.role_admin
    Role.find_or_create_by!(name: 'admin')
  end

  def self.role_batale
    Role.find_or_create_by!(name: 'batale')
  end

  def self.role_btp
    Role.find_or_create_by!(name: 'btp')
  end
end
