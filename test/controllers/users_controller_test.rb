require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  # ============================================
  # USER BLUEPRINTS (PUBLIC)
  # ============================================

  test "blueprints shows user's public blueprints without authentication" do
    user = users(:member)
    get user_blueprints_path(user_id: user.id)
    assert_response :success

    # Should show public blueprints from this user
    assert_match blueprints(:public_factory).title, response.body
    assert_match blueprints(:public_dyson_sphere).title, response.body
  end

  test "blueprints does not show private blueprints" do
    user = users(:member)
    get user_blueprints_path(user_id: user.id)
    assert_response :success

    # Should NOT show private blueprints
    assert_no_match(/Private Factory Blueprint/, response.body)
    assert_no_match(/Private Dyson Sphere/, response.body)
  end

  # ============================================
  # MY BLUEPRINTS (AUTHENTICATED)
  # ============================================

  test "my_blueprints requires authentication" do
    get blueprints_users_path
    assert_redirected_to new_user_session_path
  end

  test "my_blueprints shows current user's blueprints" do
    sign_in_as(:member)
    get blueprints_users_path
    assert_response :success

    # Should show both public and private blueprints for current user
    assert_match blueprints(:public_factory).title, response.body
    assert_match blueprints(:private_factory).title, response.body
  end

  # ============================================
  # MY FAVORITES (AUTHENTICATED)
  # ============================================

  test "my_favorites requires authentication" do
    get favorites_users_path
    assert_redirected_to new_user_session_path
  end

  test "my_favorites shows voted blueprints" do
    sign_in_as(:member)
    get favorites_users_path
    assert_response :success

    # Member has voted on public_factory (from votes fixture)
    assert_match blueprints(:public_factory).title, response.body
  end

  # ============================================
  # MY COLLECTIONS (AUTHENTICATED)
  # ============================================

  test "my_collections requires authentication" do
    get collections_users_path
    assert_redirected_to new_user_session_path
  end

  test "my_collections shows current user's collections" do
    sign_in_as(:member)
    get collections_users_path
    assert_response :success

    # Should show member's collections
    assert_match collections(:member_public).name, response.body
    assert_match collections(:member_private).name, response.body
  end

  test "my_collections filters by type Public" do
    sign_in_as(:member)
    get collections_users_path, params: { type: "Public" }
    assert_response :success

    # Should show public collections
    assert_match collections(:member_public).name, response.body
  end

  test "my_collections filters by type Private" do
    sign_in_as(:member)
    get collections_users_path, params: { type: "Private" }
    assert_response :success

    # Should show private collections
    assert_match collections(:member_private).name, response.body
  end
end
