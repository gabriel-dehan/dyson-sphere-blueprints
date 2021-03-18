class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def blueprints?
    true
  end

  def my_blueprints?
    true
  end

  def my_collections?
    true
  end
end
