require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  # ============================================
  # INDEX TESTS
  # ============================================

  test "index renders without authentication" do
    get collections_path
    assert_response :success
  end

  test "index shows only public collections with blueprints" do
    get collections_path
    assert_response :success

    # Should see public collections that have blueprints
    assert_match collections(:member_public).name, response.body
  end

  # ============================================
  # SHOW TESTS
  # ============================================

  test "show renders public collection" do
    get collection_path(collections(:member_public))
    assert_response :success
    assert_match collections(:member_public).name, response.body
  end

  test "show denies access to private collection for non-owner" do
    get collection_path(collections(:member_private))
    assert_redirected_to root_path
  end

  test "show allows owner to view private collection" do
    sign_in_as(:member)
    get collection_path(collections(:member_private))
    assert_response :success
  end

  # ============================================
  # NEW/CREATE TESTS
  # ============================================

  test "new requires authentication" do
    get new_collection_path
    assert_redirected_to new_user_session_path
  end

  test "new renders form when authenticated" do
    sign_in_as(:member)
    get new_collection_path
    assert_response :success
    assert_select "form"
  end

  test "create requires authentication" do
    post collections_path, params: { collection: { name: "Test Collection", type: 0 } }
    assert_redirected_to new_user_session_path
  end

  test "create saves valid collection" do
    sign_in_as(:member)

    assert_difference("Collection.count", 1) do
      post collections_path, params: {
        collection: { name: "New Test Collection", type: "Public" }
      }
    end

    assert_redirected_to collection_path(Collection.last)
    follow_redirect!
    assert_match "New Test Collection", response.body
  end

  # ============================================
  # EDIT/UPDATE TESTS
  # ============================================

  test "edit requires authentication" do
    get edit_collection_path(collections(:member_public))
    assert_redirected_to new_user_session_path
  end

  test "edit accessible by owner" do
    sign_in_as(:member)
    get edit_collection_path(collections(:member_public))
    assert_response :success
  end

  test "edit denied for non-owner" do
    sign_in_as(:other_user)

    assert_raises(ActiveRecord::RecordNotFound) do
      get edit_collection_path(collections(:member_public))
    end
  end

  test "update accessible by owner" do
    sign_in_as(:member)
    collection = collections(:member_public)

    patch collection_path(collection), params: {
      collection: { name: "Updated Name" }
    }

    assert_redirected_to collection_path(collection)
    follow_redirect!
    assert_match "Updated Name", response.body
  end

  # ============================================
  # DESTROY TESTS
  # ============================================

  test "destroy requires authentication" do
    delete collection_path(collections(:member_public))
    assert_redirected_to new_user_session_path
  end

  test "destroy accessible by owner" do
    sign_in_as(:member)

    # Create a new collection to delete (to avoid fixture dependency issues)
    post collections_path, params: {
      collection: { name: "To Be Deleted", type: "Public" }
    }
    collection = Collection.last

    assert_difference("Collection.count", -1) do
      delete collection_path(collection)
    end

    assert_redirected_to collections_users_path
  end

  test "destroy denied for non-owner" do
    sign_in_as(:other_user)

    assert_raises(ActiveRecord::RecordNotFound) do
      delete collection_path(collections(:member_public))
    end
  end

  # ============================================
  # BULK DOWNLOAD TESTS
  # ============================================

  # Note: Bulk download involves complex file I/O and temp files
  # This test is deferred to Phase B where we can properly set up the file handling
  test "bulk_download works without authentication" do
    skip "Bulk download involves complex temp file handling - to be added in Phase B"
  end
end
