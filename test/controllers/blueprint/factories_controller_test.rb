require "test_helper"

class Blueprint::FactoriesControllerTest < ActionDispatch::IntegrationTest
  # ============================================
  # NEW TESTS
  # ============================================

  test "new requires authentication" do
    get new_blueprint_factory_path
    assert_redirected_to new_user_session_path
  end

  test "new renders form when authenticated" do
    sign_in_as(:member)
    get new_blueprint_factory_path
    assert_response :success
    assert_select "form"
  end

  # ============================================
  # EDIT TESTS
  # ============================================

  test "edit requires authentication" do
    get edit_blueprint_factory_path(blueprints(:public_factory))
    assert_redirected_to new_user_session_path
  end

  test "edit accessible by owner" do
    sign_in_as(:member)
    get edit_blueprint_factory_path(blueprints(:public_factory))
    assert_response :success
    assert_select "form"
  end

  test "edit denied for non-owner" do
    sign_in_as(:other_user)
    get edit_blueprint_factory_path(blueprints(:public_factory))
    # Should redirect due to authorization failure
    assert_redirected_to root_path
  end

  # ============================================
  # CREATE TESTS
  # ============================================

  test "create requires authentication" do
    post blueprint_factories_path, params: {
      blueprint_factory: { title: "Test", collection: collections(:member_public).id },
    }
    assert_redirected_to new_user_session_path
  end

  test "create with valid data saves blueprint and redirects" do
    sign_in_as(:member)

    assert_difference("Blueprint::Factory.count", 1) do
      post blueprint_factories_path, params: {
        blueprint_factory: {
          title: "My New Factory Blueprint",
          collection: collections(:member_public).id,
          encoded_blueprint: sample_factory_code,
          cover_picture: sample_cover_picture,
        },
        tag_list: "production,logistics",
      }
    end

    blueprint = Blueprint::Factory.last
    assert_redirected_to blueprint_path(blueprint)
    assert_equal "My New Factory Blueprint", blueprint.title
    assert_equal users(:member), blueprint.user
  end

  test "create assigns game version automatically" do
    sign_in_as(:member)

    post blueprint_factories_path, params: {
      blueprint_factory: {
        title: "Auto Version Blueprint",
        collection: collections(:member_public).id,
        encoded_blueprint: sample_factory_code,
        cover_picture: sample_cover_picture,
      },
      tag_list: "power",
    }

    blueprint = Blueprint::Factory.last
    assert_equal "Dyson Sphere Program", blueprint.game_version.name
    assert_not_nil blueprint.game_version_string
  end

  test "create with invalid data renders errors" do
    sign_in_as(:member)

    # Missing required fields
    assert_no_difference("Blueprint::Factory.count") do
      post blueprint_factories_path, params: {
        blueprint_factory: {
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

    assert_no_difference("Blueprint::Factory.count") do
      post blueprint_factories_path, params: {
        blueprint_factory: {
          title: "Invalid Blueprint",
          collection: collections(:member_public).id,
          encoded_blueprint: "INVALID_BLUEPRINT_CODE",
          cover_picture: sample_cover_picture,
        },
        tag_list: "test",
      }
    end

    assert_response :success
    # Should show error about invalid blueprint format
  end

  # ============================================
  # UPDATE TESTS
  # ============================================

  test "update requires authentication" do
    patch blueprint_factory_path(blueprints(:public_factory)), params: {
      blueprint_factory: { title: "Updated Title", collection: collections(:member_public).id },
    }
    assert_redirected_to new_user_session_path
  end

  test "update accessible by owner" do
    sign_in_as(:member)
    blueprint = blueprints(:public_factory)

    patch blueprint_factory_path(blueprint), params: {
      blueprint_factory: {
        title: "Updated Title",
        collection: collections(:member_public).id,
      },
      tag_list: "production,logistics",
    }

    assert_redirected_to blueprint_path(blueprint)
    follow_redirect!
    assert_match /Updated Title/, response.body
  end

  test "update denied for non-owner" do
    sign_in_as(:other_user)

    assert_raises(ActiveRecord::RecordNotFound) do
      patch blueprint_factory_path(blueprints(:public_factory)), params: {
        blueprint_factory: {
          title: "Hacked Title",
          collection: collections(:other_public).id,
        },
      }
    end
  end
end
