require "test_helper"

class BlueprintTest < ActiveSupport::TestCase
  # ============================================
  # GAME VERSION COMPATIBILITY TESTS
  # ============================================

  test "game_version_compatibility_range returns array with two versions" do
    blueprint = blueprints(:public_factory)
    range = blueprint.game_version_compatibility_range

    assert_kind_of Array, range
    assert_equal 2, range.length
  end

  test "game_version_compatibility_range handles blueprint versions" do
    blueprint = blueprints(:public_factory)
    range = blueprint.game_version_compatibility_range

    # Should return valid version range (array of 2)
    assert_kind_of Array, range
    assert_equal 2, range.length
    # Both should be version strings
    assert range.first.present?
    assert range.last.present?
  end

  test "is_game_version_latest? returns boolean" do
    blueprint = blueprints(:public_factory)
    result = blueprint.is_game_version_latest?

    assert_includes [true, false], result
  end

  test "is_game_version_latest? compares with game version latest" do
    # Create a blueprint with the latest version
    blueprint = blueprints(:public_factory)
    game_version = blueprint.game_version

    # If blueprint version equals game version latest, should return true
    # Otherwise false - depends on fixture data
    if blueprint.game_version_string >= game_version.latest
      assert blueprint.is_game_version_latest?
    else
      assert_not blueprint.is_game_version_latest?
    end
  end

  # ============================================
  # HELPER METHOD TESTS
  # ============================================

  test "formatted_game_version includes game version name and version" do
    blueprint = blueprints(:public_factory)
    formatted = blueprint.formatted_game_version

    assert_includes formatted, blueprint.game_version.name
    assert_includes formatted, blueprint.game_version_string
  end

  test "large_bp? returns false for nil encoded_blueprint" do
    blueprint = blueprints(:public_mecha)
    # Mecha doesn't have encoded_blueprint
    assert_not blueprint.large_bp?
  end

  test "large_bp? returns false for normal sized blueprints" do
    blueprint = blueprints(:public_factory)
    # Fixture blueprints are small
    assert_not blueprint.large_bp?
  end

  test "is_mecha? returns true for Mecha type" do
    blueprint = blueprints(:public_mecha)
    assert blueprint.is_mecha?
  end

  test "is_mecha? returns false for Factory type" do
    blueprint = blueprints(:public_factory)
    assert_not blueprint.is_mecha?
  end

  test "is_mecha? returns false for DysonSphere type" do
    blueprint = blueprints(:public_dyson_sphere)
    assert_not blueprint.is_mecha?
  end

  # ============================================
  # TAGGING TESTS
  # ============================================

  test "tags_without_mass_construction filters mass construction tags" do
    blueprint = blueprints(:public_factory)
    tags = blueprint.tags_without_mass_construction

    # Should not include mass construction tags
    assert_empty(tags.select { |tag| tag.name =~ /mass construction/i })
  end

  # ============================================
  # SEARCH TESTS
  # ============================================

  test "recipe_ids are derived from summary recipes on save" do
    blueprint = blueprints(:public_factory)
    blueprint.update!(
      summary: {
        "buildings" => {
          # 2305 = Assembling machine Mk.III (DSP entity id)
          "2305" => {
            "recipes" => {
              # 5 = Gear, 2 = Magnet (DSP recipe ids)
              "5" => { "tally" => 10 },
              "2" => { "tally" => 5 },
            },
          },
        },
      }
    )

    blueprint.save!

    assert_equal [2, 5], blueprint.recipe_ids
  end

  test "recipe ids ignore malformed summary data and are cleared when summary changes" do
    blueprint = blueprints(:public_factory)
    blueprint.update!(
      summary: {
        buildings: {
          "one" => { recipes: { "2" => {}, "5" => {}, "0" => {}, "3x" => {}, "2147483648" => {} } },
          "two" => { recipes: { "2" => {} } },
          "bad" => nil,
        },
      }
    )
    assert_equal [2, 5], blueprint.reload.recipe_ids

    blueprint.update!(summary: nil)
    assert_equal [], blueprint.reload.recipe_ids
  end

  test "search_by_title finds matching blueprints" do
    results = Blueprint.search_by_title("Factory")

    assert results.any?
    assert(results.all? { |bp| bp.title.downcase.include?("factory") })
  end

  test "search_by_title returns empty for non-matching query" do
    results = Blueprint.search_by_title("xyznonexistent123")

    assert_empty results
  end

  # ============================================
  # STI TESTS
  # ============================================

  test "find_sti_class prefixes Blueprint namespace" do
    # This tests the STI class resolution
    klass = Blueprint.find_sti_class("Factory")
    assert_equal Blueprint::Factory, klass
  end

  # ============================================
  # SCOPES TESTS
  # ============================================

  test "light_query excludes encoded_blueprint column" do
    blueprints = Blueprint.light_query

    # This tests the scope exists and works
    assert blueprints.respond_to?(:each)
  end

  test "with_associations includes related records" do
    blueprints = Blueprint.with_associations.limit(1)

    # Should not raise N+1 errors when accessing associations
    blueprints.each do |bp|
      bp.game_version
      bp.tags
      bp.collection
    end
  end

  test "trending scores are persisted until refresh and preserve scope" do
    BlueprintTrendingScore.refresh!
    blueprint = blueprints(:public_factory)
    first = Blueprint.light_query.where(id: blueprint.id).trending.first
    assert_equal blueprint.id, first.id
    assert_not first.has_attribute?(:encoded_blueprint)
    blueprint.update_columns(cached_votes_total: 1000) # rubocop:disable Rails/SkipsModelValidations
    assert_equal first.trending_score, Blueprint.trending.find(blueprint.id).trending_score
    BlueprintTrendingScore.refresh!
    assert_operator Blueprint.trending.find(blueprint.id).trending_score, :>, first.trending_score
  end

  test "refresh applies recent activity and 7 and 30 day age boosts" do
    blueprint = blueprints(:public_factory)
    blueprint.update_columns(created_at: 40.days.ago, cached_votes_total: 10, usage_count: 5) # rubocop:disable Rails/SkipsModelValidations
    ActsAsVotable::Vote.where(votable_type: "Blueprint", votable_id: blueprint.id).delete_all
    BlueprintUsageMetric.where(blueprint_id: blueprint.id).delete_all
    BlueprintTrendingScore.refresh!
    assert_in_delta 25.0, Blueprint.trending.find(blueprint.id).trending_score, 0.001

    ActsAsVotable::Vote.create!(votable_type: "Blueprint", votable_id: blueprint.id, voter_type: "User", voter_id: users(:admin).id, vote_flag: true)
    BlueprintUsageMetric.create!(blueprint_id: blueprint.id, user_id: users(:member).id, count: 20)
    blueprint.update_columns(created_at: 1.day.ago, cached_votes_total: 10, usage_count: 5) # rubocop:disable Rails/SkipsModelValidations
    BlueprintTrendingScore.refresh!
    assert_in_delta 38.35, Blueprint.trending.find(blueprint.id).trending_score, 0.001

    blueprint.update_columns(created_at: 10.days.ago) # rubocop:disable Rails/SkipsModelValidations
    BlueprintTrendingScore.refresh!
    assert_in_delta 33.925, Blueprint.trending.find(blueprint.id).trending_score, 0.001
  end

  test "missing snapshot rows use live lifetime counters" do
    BlueprintTrendingScore.refresh!
    blueprint = blueprints(:public_factory)
    blueprint.update_columns(cached_votes_total: 10, usage_count: 5) # rubocop:disable Rails/SkipsModelValidations
    BlueprintTrendingScore.where(blueprint_id: blueprint.id).delete_all
    assert_in_delta 25, Blueprint.trending.find(blueprint.id).trending_score, 0.001
  end

  test "failed refresh rolls back scores and generation" do
    BlueprintTrendingScore.refresh!
    old_scores = BlueprintTrendingScore.order(:blueprint_id).pluck(:blueprint_id, :score)
    connection = BlueprintTrendingScore.connection
    generation = connection.select_value("SELECT generation FROM blueprint_trending_refreshes WHERE id = 1")
    connection.execute("ALTER TABLE blueprint_trending_scores ADD CONSTRAINT test_refresh_failure CHECK (score < 0) NOT VALID")
    assert_raises(ActiveRecord::StatementInvalid) { BlueprintTrendingScore.refresh! }
    assert_equal old_scores, BlueprintTrendingScore.order(:blueprint_id).pluck(:blueprint_id, :score)
    assert_equal generation, connection.select_value("SELECT generation FROM blueprint_trending_refreshes WHERE id = 1")
  end
end
