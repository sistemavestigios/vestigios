class User
  include Mongoid::Document # Módulo necessário para persistir esse objeto como documento no banco de dados
  include Mongoid::Timestamps # Módulo responsável por setar os timestamps created_at e updated_at do documento
  devise :database_authenticatable, :trackable, :validatable

  ## Database authenticatable
  field :name,               type: String
  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  belongs_to :role
  validates :name, presence: true

  def admin?
    role.name == 'admin'
  end

  def can_change_role_for_user?(user)
    return false if user.present? && user.admin?
    admin?
  end

  def first_name
    name.split(' ').first
  end

  def last_name
    name.split(' ').last
  end
end
