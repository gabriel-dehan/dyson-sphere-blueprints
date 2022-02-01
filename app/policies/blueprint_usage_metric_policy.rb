class BlueprintUsageMetricPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def track?
    record.user == user
  end
end
