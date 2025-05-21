class CommentPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def destroy?
    user.present? && record.user == user
  end

  def like?
    user.present?
  end

  def unlike?
    user.present?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end 