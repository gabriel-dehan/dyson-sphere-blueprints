require "test_helper"

class CollectionPolicyTest < ActiveSupport::TestCase
  # show? tests
  test "show? allows public collections for anonymous users" do
    collection = collections(:member_public)
    policy = CollectionPolicy.new(nil, collection)

    assert policy.show?
  end

  test "show? allows public collections for any authenticated user" do
    collection = collections(:member_public)
    other_user = users(:other_user)
    policy = CollectionPolicy.new(other_user, collection)

    assert policy.show?
  end

  test "show? denies private collections to anonymous users" do
    collection = collections(:member_private)
    policy = CollectionPolicy.new(nil, collection)

    assert_not policy.show?
  end

  test "show? denies private collections to non-owner" do
    collection = collections(:member_private)
    other_user = users(:other_user)
    policy = CollectionPolicy.new(other_user, collection)

    assert_not policy.show?
  end

  test "show? allows private collections to owner" do
    collection = collections(:member_private)
    owner = users(:member)
    policy = CollectionPolicy.new(owner, collection)

    assert policy.show?
  end

  # create? tests
  test "create? allows authenticated users" do
    collection = Collection.new
    user = users(:member)
    policy = CollectionPolicy.new(user, collection)

    assert policy.create?
  end

  # update? tests
  test "update? allows owner" do
    collection = collections(:member_public)
    owner = users(:member)
    policy = CollectionPolicy.new(owner, collection)

    assert policy.update?
  end

  test "update? denies non-owner" do
    collection = collections(:member_public)
    other_user = users(:other_user)
    policy = CollectionPolicy.new(other_user, collection)

    assert_not policy.update?
  end

  # destroy? tests
  test "destroy? allows owner" do
    collection = collections(:member_public)
    owner = users(:member)
    policy = CollectionPolicy.new(owner, collection)

    assert policy.destroy?
  end

  test "destroy? denies non-owner" do
    collection = collections(:member_public)
    other_user = users(:other_user)
    policy = CollectionPolicy.new(other_user, collection)

    assert_not policy.destroy?
  end

  # bulk_download? tests
  test "bulk_download? allows any user" do
    collection = collections(:member_public)
    policy = CollectionPolicy.new(nil, collection)

    assert policy.bulk_download?
  end
end
