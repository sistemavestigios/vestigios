class User
  include Mongoid::Document
  include Mongoid::Timestamps
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :first_name,         type: String, default: ''
  field :last_name, type: String, default: ''
  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''

  # Relação 1:n com o model Btoe::Color
  has_many :colors, class_name: 'Btoe::Color'
  # Relação 1:n com o model Btoe::Bloc
  has_many :blocs, class_name: 'Btoe::Bloc'
  accepts_nested_attributes_for :roles

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  def full_name
    return "#{first_name} #{last_name}" if first_name || last_name
    'Anônimo'
  end

  def get_roles
    names = []
    role_ids.each do |id|
      names << Role.find(id).name
    end
    names
  end

  def private_blocs?
    private = false
    blocs.each { |bloc| private = bloc.private? ? true : false }
    private
  end
end
