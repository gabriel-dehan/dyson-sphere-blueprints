require "test_helper"

class Blueprint::DysonSpheresControllerTest < ActionDispatch::IntegrationTest
  # ============================================
  # NEW TESTS
  # ============================================

  test "new requires authentication" do
    get new_blueprint_dyson_sphere_path
    assert_redirected_to new_user_session_path
  end

  test "new renders form when authenticated" do
    sign_in_as(:member)
    get new_blueprint_dyson_sphere_path
    assert_response :success
    assert_select "form"
  end

  # ============================================
  # EDIT TESTS
  # ============================================

  test "edit requires authentication" do
    get edit_blueprint_dyson_sphere_path(blueprints(:public_dyson_sphere))
    assert_redirected_to new_user_session_path
  end

  test "edit accessible by owner" do
    sign_in_as(:member)
    get edit_blueprint_dyson_sphere_path(blueprints(:public_dyson_sphere))
    assert_response :success
    assert_select "form"
  end

  test "edit denied for non-owner" do
    sign_in_as(:other_user)
    get edit_blueprint_dyson_sphere_path(blueprints(:public_dyson_sphere))
    # Should redirect due to authorization failure
    assert_redirected_to root_path
  end

  # ============================================
  # CREATE TESTS
  # ============================================

  test "create requires authentication" do
    post blueprint_dyson_spheres_path, params: {
      blueprint_dyson_sphere: { title: "Test", collection: collections(:member_public).id },
    }
    assert_redirected_to new_user_session_path
  end

  test "create with valid data saves blueprint and redirects" do
    sign_in_as(:member)

    assert_difference("Blueprint::DysonSphere.count", 1) do
      post blueprint_dyson_spheres_path, params: {
        blueprint_dyson_sphere: {
          title: "My New Dyson Sphere",
          collection: collections(:member_public).id,
          encoded_blueprint: sample_dyson_sphere_code,
          cover_picture: sample_cover_picture,
        },
        tag_list: "sphere,dense",
      }
    end

    blueprint = Blueprint::DysonSphere.last
    assert_redirected_to blueprint_path(blueprint)
    assert_equal "My New Dyson Sphere", blueprint.title
    assert_equal users(:member), blueprint.user
  end

  test "create assigns mod and version automatically" do
    sign_in_as(:member)

    post blueprint_dyson_spheres_path, params: {
      blueprint_dyson_sphere: {
        title: "Auto Mod Dyson Sphere",
        collection: collections(:member_public).id,
        encoded_blueprint: sample_dyson_sphere_code,
        cover_picture: sample_cover_picture,
      },
      tag_list: "sphere",
    }

    blueprint = Blueprint::DysonSphere.last
    assert_equal "Dyson Sphere Program", blueprint.mod.name
    assert_not_nil blueprint.mod_version
  end

  test "create with invalid data renders errors" do
    sign_in_as(:member)

    # Missing required fields
    assert_no_difference("Blueprint::DysonSphere.count") do
      post blueprint_dyson_spheres_path, params: {
        blueprint_dyson_sphere: {
          title: "",
          collection: collections(:member_public).id,
          encoded_blueprint: "",
        },
        tag_list: "",
      }
    end

    # Should re-render the form with errors
    assert_response :success
    assert_select ".field_with_errors", minimum: 1
  end

  test "create with invalid blueprint code renders error" do
    sign_in_as(:member)

    assert_no_difference("Blueprint::DysonSphere.count") do
      post blueprint_dyson_spheres_path, params: {
        blueprint_dyson_sphere: {
          title: "Invalid Dyson Sphere",
          collection: collections(:member_public).id,
          encoded_blueprint: "INVALID_DYSON_CODE",
          cover_picture: sample_cover_picture,
        },
        tag_list: "sphere",
      }
    end

    assert_response :success
  end

  # ============================================
  # UPDATE TESTS
  # ============================================

  test "update requires authentication" do
    patch blueprint_dyson_sphere_path(blueprints(:public_dyson_sphere)), params: {
      blueprint_dyson_sphere: { title: "Updated Title", collection: collections(:member_public).id },
    }
    assert_redirected_to new_user_session_path
  end

  test "update accessible by owner" do
    sign_in_as(:member)
    blueprint = blueprints(:public_dyson_sphere)

    patch blueprint_dyson_sphere_path(blueprint), params: {
      blueprint_dyson_sphere: {
        title: "Updated Dyson Title",
        collection: collections(:member_public).id,
      },
      tag_list: "solar,energy",
    }

    assert_redirected_to blueprint_path(blueprint)
    follow_redirect!
    assert_match /Updated Dyson Title/, response.body
  end

  test "update denied for non-owner" do
    sign_in_as(:other_user)

    assert_raises(ActiveRecord::RecordNotFound) do
      patch blueprint_dyson_sphere_path(blueprints(:public_dyson_sphere)), params: {
        blueprint_dyson_sphere: {
          title: "Hacked Title",
          collection: collections(:other_public).id,
        },
      }
    end
  end
end
