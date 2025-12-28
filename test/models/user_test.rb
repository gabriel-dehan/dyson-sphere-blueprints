require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin? returns true for admin role" do
    admin = users(:admin)
    assert admin.admin?
  end

  test "admin? returns false for member role" do
    member = users(:member)
    assert_not member.admin?
  end

  test "create_default_collections creates 5 collections for new user" do
    user = User.new(
      username: "new_user_#{SecureRandom.hex(4)}",
      email: "newuser_#{SecureRandom.hex(4)}@example.com",
      password: "password123"
    )

    assert_difference("Collection.count", 5) do
      user.save!
    end

    # Verify the collections were created with correct names and types
    collection_names = user.collections.pluck(:name)
    assert_includes collection_names, "Public"
    assert_includes collection_names, "Private"
    assert_includes collection_names, "Mechas"
    assert_includes collection_names, "Factories"
    assert_includes collection_names, "Dyson Spheres"

    # Verify collection types
    assert_equal 1, user.collections.where(name: "Private", type: "Private").count
    assert_equal 4, user.collections.where(type: "Public").count
  end

  test "find_for_discord_oauth finds existing user by uid" do
    existing_user = users(:member)
    existing_user.update!(provider: "discord", uid: "123456789")

    auth = OmniAuth::AuthHash.new(
      provider: "discord",
      uid: "123456789",
      info: {
        email: existing_user.email,
        name: "Updated Discord Name",
        image: "https://cdn.discord.com/avatar.png"
      },
      credentials: {
        token: "new_token_abc",
        expires_at: 1.day.from_now.to_i
      }
    )

    found_user = User.find_for_discord_oauth(auth)

    assert_equal existing_user.id, found_user.id
    # Username should not change for existing users
    assert_equal existing_user.username, found_user.username
    # But other fields should update
    assert_equal "new_token_abc", found_user.token
  end

  test "find_for_discord_oauth finds existing user by email when no uid match" do
    existing_user = users(:member)
    # User has no provider/uid set (regular signup)

    auth = OmniAuth::AuthHash.new(
      provider: "discord",
      uid: "987654321",
      info: {
        email: existing_user.email,
        name: "Discord Name",
        image: "https://cdn.discord.com/avatar.png"
      },
      credentials: {
        token: "token_xyz",
        expires_at: 1.day.from_now.to_i
      }
    )

    found_user = User.find_for_discord_oauth(auth)

    assert_equal existing_user.id, found_user.id
    # Provider and uid should now be set
    assert_equal "discord", found_user.provider
    assert_equal "987654321", found_user.uid
  end

  test "find_for_discord_oauth creates new user when not found" do
    auth = OmniAuth::AuthHash.new(
      provider: "discord",
      uid: "brand_new_user_123",
      info: {
        email: "brand_new_#{SecureRandom.hex(4)}@discord.com",
        name: "Brand New User",
        image: "https://cdn.discord.com/new_avatar.png"
      },
      credentials: {
        token: "new_user_token",
        expires_at: 1.day.from_now.to_i
      }
    )

    assert_difference("User.count", 1) do
      new_user = User.find_for_discord_oauth(auth)

      assert new_user.persisted?
      assert_equal "discord", new_user.provider
      assert_equal "brand_new_user_123", new_user.uid
      assert_equal "Brand New User", new_user.username
      assert_equal auth.info.email, new_user.email
      assert_equal "new_user_token", new_user.token
    end
  end

  test "find_for_discord_oauth updates discord avatar url" do
    existing_user = users(:member)
    existing_user.update!(provider: "discord", uid: "avatar_test_123")

    new_avatar_url = "https://cdn.discord.com/avatars/new_avatar_#{SecureRandom.hex(4)}.png"

    auth = OmniAuth::AuthHash.new(
      provider: "discord",
      uid: "avatar_test_123",
      info: {
        email: existing_user.email,
        name: "Discord User",
        image: new_avatar_url
      },
      credentials: {
        token: "token",
        expires_at: 1.day.from_now.to_i
      }
    )

    found_user = User.find_for_discord_oauth(auth)

    assert_equal new_avatar_url, found_user.discord_avatar_url
  end
end
