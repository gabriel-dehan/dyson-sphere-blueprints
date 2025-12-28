require "test_helper"

class BlueprintPolicyTest < ActiveSupport::TestCase
  # show? tests
  test "show? allows public blueprints for anonymous users" do
    blueprint = blueprints(:public_factory)
    policy = BlueprintPolicy.new(nil, blueprint)

    assert policy.show?
  end

  test "show? allows public blueprints for any authenticated user" do
    blueprint = blueprints(:public_factory)
    other_user = users(:other_user)
    policy = BlueprintPolicy.new(other_user, blueprint)

    assert policy.show?
  end

  test "show? denies private blueprints to anonymous users" do
    blueprint = blueprints(:private_factory)
    policy = BlueprintPolicy.new(nil, blueprint)

    assert_not policy.show?
  end

  test "show? denies private blueprints to non-owner" do
    blueprint = blueprints(:private_factory)
    # private_factory belongs to member, other_user is not the owner
    other_user = users(:other_user)
    policy = BlueprintPolicy.new(other_user, blueprint)

    assert_not policy.show?
  end

  test "show? allows private blueprints to owner" do
    blueprint = blueprints(:private_factory)
    # private_factory belongs to member
    owner = users(:member)
    policy = BlueprintPolicy.new(owner, blueprint)

    assert policy.show?
  end

  test "show? allows private blueprints to admin" do
    blueprint = blueprints(:private_factory)
    admin = users(:admin)
    policy = BlueprintPolicy.new(admin, blueprint)

    assert policy.show?
  end

  # create? tests
  test "create? allows authenticated users" do
    blueprint = Blueprint::Factory.new
    user = users(:member)
    policy = BlueprintPolicy.new(user, blueprint)

    assert policy.create?
  end

  test "create? allows even without user (policy always returns true)" do
    blueprint = Blueprint::Factory.new
    policy = BlueprintPolicy.new(nil, blueprint)

    # The policy returns true for create?, though controller requires auth
    assert policy.create?
  end

  # update? tests
  test "update? allows owner" do
    blueprint = blueprints(:public_factory)
    owner = users(:member)
    policy = BlueprintPolicy.new(owner, blueprint)

    assert policy.update?
  end

  test "update? denies non-owner" do
    blueprint = blueprints(:public_factory)
    other_user = users(:other_user)
    policy = BlueprintPolicy.new(other_user, blueprint)

    assert_not policy.update?
  end

  test "update? denies admin who is not owner" do
    # public_factory belongs to member, not admin
    blueprint = blueprints(:public_factory)
    admin = users(:admin)
    policy = BlueprintPolicy.new(admin, blueprint)

    # Admin cannot update someone else's blueprint
    assert_not policy.update?
  end

  # destroy? tests
  test "destroy? allows owner" do
    blueprint = blueprints(:public_factory)
    owner = users(:member)
    policy = BlueprintPolicy.new(owner, blueprint)

    assert policy.destroy?
  end

  test "destroy? denies non-owner" do
    blueprint = blueprints(:public_factory)
    other_user = users(:other_user)
    policy = BlueprintPolicy.new(other_user, blueprint)

    assert_not policy.destroy?
  end

  test "destroy? denies admin who is not owner" do
    blueprint = blueprints(:public_factory)
    admin = users(:admin)
    policy = BlueprintPolicy.new(admin, blueprint)

    # Admin cannot delete someone else's blueprint
    assert_not policy.destroy?
  end

  # like? and unlike? tests
  test "like? allows any user" do
    blueprint = blueprints(:public_factory)
    policy = BlueprintPolicy.new(nil, blueprint)

    assert policy.like?
  end

  test "unlike? allows any user" do
    blueprint = blueprints(:public_factory)
    policy = BlueprintPolicy.new(nil, blueprint)

    assert policy.unlike?
  end

  # code? tests
  test "code? allows any user" do
    blueprint = blueprints(:public_factory)
    policy = BlueprintPolicy.new(nil, blueprint)

    assert policy.code?
  end
end
