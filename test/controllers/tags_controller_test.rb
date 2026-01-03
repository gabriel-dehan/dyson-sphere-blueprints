require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  # ============================================
  # INDEX
  # ============================================

  test "index returns JSON array of tags" do
    get tags_path, as: :json
    assert_response :success

    tags = JSON.parse(response.body)
    assert_kind_of Array, tags
    # Should include tags from fixtures (lowercase)
    assert_includes tags, "production"
    assert_includes tags, "logistics"
  end

  test "index does not require authentication" do
    get tags_path, as: :json
    assert_response :success
  end

  test "index filters by category" do
    get tags_path, params: { category: "factories" }, as: :json
    assert_response :success

    tags = JSON.parse(response.body)
    # Should only return factories category tags (lowercase)
    assert_includes tags, "production"
    assert_includes tags, "logistics"
    # Should NOT include dyson_sphere category tags
    assert_not_includes tags, "sphere"
  end

  # ============================================
  # PROFANITY CHECK
  # ============================================

  test "profanity_check allows clean words" do
    sign_in_as(:member)
    post profanity_check_tags_path, params: { tag: "Production" }, as: :json
    assert_response :success

    # Should return false (not profane)
    result = JSON.parse(response.body)
    assert_equal false, result
  end

  # NOTE: Testing actual profane words would require knowing the profanity filter dict
  # We test the endpoint works and returns boolean
  test "profanity_check returns boolean" do
    sign_in_as(:member)
    post profanity_check_tags_path, params: { tag: "TestWord" }, as: :json
    assert_response :success

    result = JSON.parse(response.body)
    assert_includes [true, false], result
  end
end
