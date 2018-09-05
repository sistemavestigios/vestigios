class Batale::BlocPolicy
  attr_reader :user, :bloc

  def initialize(user, bloc)
    @user = user
    @bloc = bloc
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

  def createBloc?
    create?
  end
end
