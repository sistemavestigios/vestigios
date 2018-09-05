class UserPolicy
  attr_reader :user, :register

  def initialize(user, register)
    @user = user
    @register = register
  end

  def index?
    @user.has_role? :admin
  end

  def update?
    @user.has_role? :admin
  end

  def edit?
    @user.has_role? :admin
  end
end
