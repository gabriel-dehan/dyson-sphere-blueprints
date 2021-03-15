require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get collections_index_url
    assert_response :success
  end

  test "should get show" do
    get collections_show_url
    assert_response :success
  end

  test "should get new" do
    get collections_new_url
    assert_response :success
  end

  test "should get edit" do
    get collections_edit_url
    assert_response :success
  end
end
