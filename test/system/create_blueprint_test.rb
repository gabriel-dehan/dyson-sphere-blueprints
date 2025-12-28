require "application_system_test_case"

class CreateBlueprintTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:member)
  end

  test "authenticated user can access new factory blueprint form" do
    sign_in @user

    visit new_blueprint_factory_path

    # Should see the form
    assert_selector "form"
    assert_selector "body", text: /factory|blueprint/i
  end

  test "authenticated user can access new dyson sphere blueprint form" do
    sign_in @user

    visit new_blueprint_dyson_sphere_path

    # Should see the form
    assert_selector "form"
    assert_selector "body", text: /dyson|sphere|blueprint/i
  end

  test "unauthenticated user is redirected to login" do
    visit new_blueprint_factory_path

    # Should be redirected to login or see login prompt
    assert_current_path new_user_session_path
  end
end
