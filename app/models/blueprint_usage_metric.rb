class BlueprintUsageMetric < ApplicationRecord
  belongs_to :user
  belongs_to :blueprint, class_name: "Blueprint"

  validate :can_update?

  before_save :update_last_used_at
  after_destroy :reset_blueprint_tally
  after_save :update_blueprint_tally

  def update_last_used_at
    self.last_used_at = DateTime.now
  end

  def update_blueprint_tally
    if saved_change_to_attribute?(:count)
      blueprint.usage_count += 1
      blueprint.save!
    end
  end

  def reset_blueprint_tally
    blueprint.usage_count = 0
    blueprint.save!
  end

  def can_update?
    errors.add(:count, "usage can't be counted more than once per hour") if id && last_used_at && (last_used_at + 1.hour > DateTime.now)
  end
end
