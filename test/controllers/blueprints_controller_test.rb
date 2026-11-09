require "test_helper"

class BlueprintsControllerTest < ActionDispatch::IntegrationTest
  # ============================================
  # INDEX TESTS
  # ============================================

  test "index renders successfully without authentication" do
    get blueprints_path
    assert_response :success
    assert_select "title", /Blueprints/i
  end

  test "index shows only public blueprints" do
    get blueprints_path
    assert_response :success

    # Should see public blueprints
    assert_match blueprints(:public_factory).title, response.body
    assert_match blueprints(:public_dyson_sphere).title, response.body

    # Should NOT see private blueprints
    assert_no_match(/Private Factory Blueprint/, response.body)
    assert_no_match(/Private Dyson Sphere/, response.body)
  end

  test "index filters by blueprint type" do
    get blueprints_path, params: { type: "factories" }
    assert_response :success

    # Should see factory blueprints
    assert_match blueprints(:public_factory).title, response.body

    # Should NOT see dyson sphere blueprints
    assert_no_match(/Public Dyson Sphere/, response.body)
  end

  test "index filters by tags" do
    get blueprints_path, params: { tags: "production" }
    assert_response :success

    # Should see blueprints with production tag
    assert_match blueprints(:public_factory).title, response.body
  end

  test "index filters by recipe ids" do
    public_factory = blueprints(:public_factory)
    public_factory.update!(
      summary: {
        "buildings" => {
          # 2305 = Assembling machine Mk.III (DSP entity id)
          "2305" => {
            "recipes" => {
              # 5 = Gear (DSP recipe id)
              "5" => { "tally" => 10 }
            }
          }
        }
      }
    )

    get blueprints_path, params: { recipe: "5" }
    assert_response :success

    assert_match public_factory.title, response.body
    assert_no_match(/Public Dyson Sphere/, response.body)
  end

  test "recipe filter requires every selected recipe" do
    matching = blueprints(:public_factory)
    other = blueprints(:other_user_factory)
    matching.update!(summary: { buildings: { "1" => { recipes: { "2" => {}, "5" => {} } } } })
    other.update!(summary: { buildings: { "1" => { recipes: { "5" => {} } } } })

    get blueprints_path, params: { recipe: "2,5" }
    assert_response :success
    assert_match matching.title, response.body
    assert_no_match other.title, response.body
  end

  test "recipe results are not cached while backfill changes the projection" do
    blueprint = blueprints(:public_factory)
    blueprint.update_columns(recipe_ids: nil)
    get blueprints_path, params: { recipe: "5" }
    assert_response :success
    assert_match(/no-store/, response.headers["Cache-Control"])
    etag = response.headers["ETag"]

    blueprint.update_columns(recipe_ids: [5])
    get blueprints_path, params: { recipe: "5" }, headers: { "If-None-Match" => etag.to_s, "If-Modified-Since" => 1.day.from_now.httpdate }
    assert_response :success
    assert_match blueprint.title, response.body
  end

  test "recipe filtering and trending work together without caching backfill results" do
    blueprint = blueprints(:public_factory)
    blueprint.update!(summary: { buildings: { "1" => { recipes: { "5" => {} } } } })
    BlueprintTrendingScore.refresh!

    get blueprints_path, params: { recipe: "5", order: "trending" }
    assert_response :success
    assert_match blueprint.title, response.body
    assert_match(/no-store/, response.headers["Cache-Control"])
  end

  test "recipe filter rejects malformed recipe identifiers" do
    assert_raises(ActionController::BadRequest) do
      get blueprints_path, params: { recipe: "5xyz" }
    end
  end

  test "index orders by recent by default" do
    get blueprints_path, params: { order: "recent" }
    assert_response :success
  end

  test "index orders by popular" do
    get blueprints_path, params: { order: "popular" }
    assert_response :success
  end

  test "trending preserves public and type filters and invalidates cached ranking" do
    BlueprintTrendingScore.refresh!
    get blueprints_path, params: { order: "trending", type: "factories" }
    assert_response :success
    assert_match blueprints(:public_factory).title, response.body
    assert_no_match blueprints(:private_factory).title, response.body
    assert_no_match blueprints(:public_dyson_sphere).title, response.body
    etag = response.headers["ETag"]
    assert_match(/max-age=0/, response.headers["Cache-Control"])
    BlueprintTrendingScore.refresh!
    get blueprints_path, params: { order: "trending", type: "factories" }, headers: { "If-None-Match" => etag }
    assert_response :success
    assert_not_equal etag, response.headers["ETag"]
  end

  test "trending works before the snapshot migration" do
    connection = Blueprint.connection
    connection.execute("ALTER TABLE blueprint_trending_refreshes RENAME TO temporarily_missing_trending_refreshes")
    get blueprints_path, params: { order: "trending", type: "factories" }
    assert_response :success
    assert_match blueprints(:public_factory).title, response.body
    assert_no_match blueprints(:private_factory).title, response.body
    connection.execute("ALTER TABLE temporarily_missing_trending_refreshes RENAME TO blueprint_trending_refreshes")
    connection.execute("INSERT INTO blueprint_trending_refreshes (id, generation) VALUES (1, 0) ON CONFLICT (id) DO UPDATE SET generation = 0")
    get blueprints_path, params: { order: "trending", type: "factories" }
    assert_response :success
    etag = response.headers["ETag"]
    BlueprintTrendingScore.refresh!
    get blueprints_path, params: { order: "trending", type: "factories" }, headers: { "If-None-Match" => etag }
    assert_response :success
    assert_not_equal etag, response.headers["ETag"]
  ensure
    connection.execute("ALTER TABLE temporarily_missing_trending_refreshes RENAME TO blueprint_trending_refreshes") if connection.data_source_exists?("temporarily_missing_trending_refreshes")
  end

  # ============================================
  # SHOW TESTS
  # ============================================

  test "show renders factory blueprint" do
    get blueprint_path(blueprints(:public_factory))
    assert_response :success
    assert_match blueprints(:public_factory).title, response.body
  end

  test "show renders dyson sphere blueprint" do
    get blueprint_path(blueprints(:public_dyson_sphere))
    assert_response :success
    assert_match blueprints(:public_dyson_sphere).title, response.body
  end

  # NOTE: Mecha show requires blueprint_file_data which is complex to set up
  # This test is skipped for Phase A and will be added in Phase B with proper fixtures
  test "show renders mecha blueprint" do
    skip "Mecha blueprints require blueprint_file_data - to be added in Phase B"
  end

  test "show denies access to private blueprint for non-owner" do
    get blueprint_path(blueprints(:private_factory))
    assert_redirected_to root_path
  end

  test "show allows owner to view private blueprint" do
    sign_in_as(:member)
    get blueprint_path(blueprints(:private_factory))
    assert_response :success
    assert_match blueprints(:private_factory).title, response.body
  end

  test "show allows admin to view private blueprint" do
    sign_in_as(:admin)
    get blueprint_path(blueprints(:private_factory))
    assert_response :success
  end

  # ============================================
  # DESTROY TESTS
  # ============================================

  test "destroy requires authentication" do
    delete blueprint_path(blueprints(:public_factory))
    assert_redirected_to new_user_session_path
  end

  test "destroy only accessible by owner" do
    sign_in_as(:other_user)
    assert_raises(ActiveRecord::RecordNotFound) do
      delete blueprint_path(blueprints(:public_factory))
    end
  end

  test "destroy removes blueprint and redirects" do
    sign_in_as(:member)
    blueprint = blueprints(:public_factory)

    assert_difference("Blueprint.count", -1) do
      delete blueprint_path(blueprint)
    end

    assert_redirected_to blueprints_users_path
    follow_redirect!
    assert_match /deleted/i, flash[:notice]
  end

  # ============================================
  # LIKE/UNLIKE TESTS
  # ============================================

  test "like requires authentication" do
    put like_blueprint_path(blueprints(:public_factory))
    assert_redirected_to new_user_session_path
  end

  test "like adds vote and redirects" do
    sign_in_as(:other_user)
    blueprint = blueprints(:public_dyson_sphere)

    assert_difference("ActsAsVotable::Vote.count", 1) do
      put like_blueprint_path(id: blueprint.id)
    end

    assert_redirected_to blueprint_path(blueprint)
  end

  test "unlike removes vote and redirects" do
    sign_in_as(:member)
    blueprint = blueprints(:public_factory)

    # Member already has a vote on public_factory (from fixtures)
    assert_difference("ActsAsVotable::Vote.count", -1) do
      put unlike_blueprint_path(id: blueprint.id)
    end

    assert_redirected_to blueprint_path(blueprint)
  end

  # ============================================
  # TRACK TESTS
  # ============================================

  test "track requires authentication" do
    put track_blueprint_path(blueprints(:public_factory))
    assert_redirected_to new_user_session_path
  end

  test "track creates usage metric" do
    sign_in_as(:other_user)
    # Use a blueprint that other_user hasn't tracked yet
    blueprint = blueprints(:other_user_factory)

    assert_difference("BlueprintUsageMetric.count", 1) do
      put track_blueprint_path(id: blueprint.id)
    end

    assert_response :success
    assert_equal "true", response.body
  end

  # ============================================
  # CODE TESTS
  # ============================================

  test "code is accessible without authentication" do
    blueprint = blueprints(:public_factory)
    get code_blueprint_path(id: blueprint.id)
    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_equal blueprint.encoded_blueprint, response.body
  end

  test "code returns encoded blueprint as text when authenticated" do
    sign_in_as(:member)
    blueprint = blueprints(:public_factory)

    get code_blueprint_path(id: blueprint.id)

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_equal blueprint.encoded_blueprint, response.body
  end
end
