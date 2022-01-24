require "test_helper"

class StructureBlueprintsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get blueprints_index_url
    assert_response :success
  end

  test "should get show" do
    get blueprints_show_url
    assert_response :success
  end

  test "should get new" do
    get blueprints_new_url
    assert_response :success
  end

  test "should get edit" do
    get blueprints_edit_url
    assert_response :success
  end
end
