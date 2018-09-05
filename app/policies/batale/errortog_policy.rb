class Batale::ErrortogPolicy < ApplicationPolicy
  def show?
    scope.find(record.id).present?
  end
end
