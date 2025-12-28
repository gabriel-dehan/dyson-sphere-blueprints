require "test_helper"

class BlueprintUsageMetricTest < ActiveSupport::TestCase
  # ============================================
  # CAN_UPDATE? VALIDATION TESTS
  # ============================================

  test "can_update? prevents updates within 1 hour" do
    metric = blueprint_usage_metrics(:admin_used_public_dyson)
    # last_used_at is 2 hours ago, so it should be updatable

    # Simulate a recent use
    metric.last_used_at = 30.minutes.ago
    metric.count += 1

    # Should fail validation because last used was within 1 hour
    refute metric.valid?
    assert_includes metric.errors[:count], "usage can't be counted more than once per hour"
  end

  test "can_update? allows updates after 1 hour" do
    metric = blueprint_usage_metrics(:member_used_public_factory)
    # last_used_at is 1 day ago, so it should be updatable

    original_count = metric.count
    metric.count = original_count + 1

    # Should be valid because last used was more than 1 hour ago
    assert metric.valid?
  end

  # ============================================
  # CALLBACK TESTS
  # ============================================

  test "update_last_used_at sets timestamp before save" do
    # Create a new metric (don't set last_used_at manually)
    user = users(:other_user)
    blueprint = blueprints(:public_dyson_sphere)

    metric = BlueprintUsageMetric.new(
      user: user,
      blueprint: blueprint,
      count: 1
    )

    # The before_save callback will set last_used_at
    metric.save!

    # After save, last_used_at should be set to now (within last minute)
    assert_not_nil metric.last_used_at
    assert metric.last_used_at > 1.minute.ago
    assert metric.last_used_at <= DateTime.now
  end

  test "update_blueprint_tally increments count on save" do
    user = users(:other_user)
    blueprint = blueprints(:public_dyson_sphere)
    original_usage = blueprint.usage_count

    metric = BlueprintUsageMetric.new(
      user: user,
      blueprint: blueprint,
      count: 1
    )
    metric.save!

    blueprint.reload
    assert_equal original_usage + 1, blueprint.usage_count
  end

  test "reset_blueprint_tally resets count on destroy" do
    metric = blueprint_usage_metrics(:member_used_public_factory)
    blueprint = metric.blueprint

    metric.destroy

    blueprint.reload
    assert_equal 0, blueprint.usage_count
  end

  # ============================================
  # ASSOCIATION TESTS
  # ============================================

  test "belongs to user" do
    metric = blueprint_usage_metrics(:member_used_public_factory)
    assert_equal users(:member), metric.user
  end

  test "belongs to blueprint" do
    metric = blueprint_usage_metrics(:member_used_public_factory)
    assert_equal blueprints(:public_factory), metric.blueprint
  end
end
