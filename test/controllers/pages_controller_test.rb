require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  # ============================================
  # HOME
  # ============================================

  test "home renders without authentication" do
    get root_path
    assert_response :success
  end

  test "home shows recent blueprints" do
    get root_path
    assert_response :success

    # Should show public blueprints
    assert_match blueprints(:public_factory).title, response.body
    assert_match blueprints(:public_dyson_sphere).title, response.body
  end

  test "home does not show private blueprints" do
    get root_path
    assert_response :success

    # Should NOT show private blueprints
    assert_no_match(/Private Factory Blueprint/, response.body)
    assert_no_match(/Private Dyson Sphere/, response.body)
  end

  # ============================================
  # HELP
  # ============================================

  test "help renders without authentication" do
    get help_path
    assert_response :success
  end

  # ============================================
  # SUPPORT
  # ============================================

  test "support renders without authentication" do
    get supportus_path
    assert_response :success
  end

  # ============================================
  # WALL OF FAME
  # ============================================

  test "wall_of_fame renders without authentication" do
    get walloffame_path
    assert_response :success
  end
end
