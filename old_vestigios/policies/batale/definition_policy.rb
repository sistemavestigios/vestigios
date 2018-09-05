class Batale::DefinitionPolicy
  attr_reader :user, :definition

  def initialize(user, definition)
    @user = user
    @definition = definition
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
