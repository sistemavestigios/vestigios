class Btoe::ColorPolicy
  attr_reader :user, :color

  def initialize(user, color)
    @user = user
    @color = color
  end

  def index?
    true
  end

  def show?
    @user.has_role?(:admin) || (@user == @color.user) || @user.has_role?(:read)
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

  def createColor?
    create?
  end
end
