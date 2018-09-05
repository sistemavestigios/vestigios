class Batale::ErrortogPolicy
  attr_reader :user, :errortog

  def initialize(user, errortog)
    @user = user
    @errortog = errortog
  end

  def index?
    true
  end

  def show?
    @user.has_role?(:admin) || @user.has_role?(:read)
  end

  def create?
    @user.has_role? :admin
  end

  def create_definition?
    @user.has_role? :admin
  end

  def new?
    @user.has_role? :admin
  end

  def update?
    @user.has_role? :admin
  end

  def edit?
    @user.has_role? :admin
  end

  def destroy?
    @user.has_role? :admin
  end
end
