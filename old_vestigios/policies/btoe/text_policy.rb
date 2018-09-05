class Btoe::TextPolicy
  attr_reader :user, :text

  def initialize(user, text)
    @user = user
    @text = text
  end

  def index?
    true
  end

  def see_more?
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
