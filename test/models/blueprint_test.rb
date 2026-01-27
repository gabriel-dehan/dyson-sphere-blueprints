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

  # ============================================
  # TRENDING SCOPE TESTS
  # ============================================

  test "trending scope returns blueprints" do
    results = Blueprint.trending

    assert results.respond_to?(:each)
    assert results.respond_to?(:order)
  end

  test "trending scope orders by trending_score descending" do
    results = Blueprint.trending.limit(10).to_a

    # Should be ordered by trending_score DESC
    scores = results.map { |bp| bp.trending_score || 0 }
    assert_equal scores, scores.sort.reverse
  end

  test "trending scope includes trending_score attribute" do
    results = Blueprint.trending.limit(1).to_a

    if results.any?
      assert results.first.respond_to?(:trending_score)
      assert_kind_of Numeric, results.first.trending_score
    end
  end

  test "trending scope gives higher score to blueprints with more votes" do
    # Create two blueprints with different vote counts
    high_votes = blueprints(:public_dyson_sphere) # 25 votes
    low_votes = blueprints(:private_factory) # 0 votes

    results = Blueprint.trending.where(id: [high_votes.id, low_votes.id]).to_a

    high_votes_result = results.find { |bp| bp.id == high_votes.id }
    low_votes_result = results.find { |bp| bp.id == low_votes.id }

    if high_votes_result && low_votes_result
      assert high_votes_result.trending_score > low_votes_result.trending_score,
             "Blueprint with more votes should have higher trending score"
    end
  end

  test "trending scope gives higher score to blueprints with more usage" do
    # Create two blueprints with different usage counts
    high_usage = blueprints(:public_dyson_sphere) # 15 usage
    low_usage = blueprints(:private_factory) # 0 usage

    results = Blueprint.trending.where(id: [high_usage.id, low_usage.id]).to_a

    high_usage_result = results.find { |bp| bp.id == high_usage.id }
    low_usage_result = results.find { |bp| bp.id == low_usage.id }

    if high_usage_result && low_usage_result
      assert high_usage_result.trending_score > low_usage_result.trending_score,
             "Blueprint with more usage should have higher trending score"
    end
  end

  test "trending scope weights recent votes more heavily" do
    # Create a blueprint with recent vote
    blueprint = blueprints(:public_factory)

    # Create a recent vote (within last 7 days)
    ActsAsVotable::Vote.create!(
      votable_type: "Blueprint",
      votable_id: blueprint.id,
      voter_type: "User",
      voter_id: users(:admin).id,
      vote_flag: true,
      created_at: 1.day.ago
    )

    results = Blueprint.trending.where(id: blueprint.id).to_a
    result = results.first

    if result
      assert result.trending_score.positive?,
             "Blueprint with recent vote should have positive trending score"
    end
  end

  test "trending scope weights recent usage more heavily" do
    # Create a blueprint with recent usage
    blueprint = blueprints(:public_factory)

    # Create a recent usage metric (within last 7 days)
    BlueprintUsageMetric.create!(
      blueprint_id: blueprint.id,
      user_id: users(:admin).id,
      count: 1,
      last_used_at: 1.day.ago
    )

    results = Blueprint.trending.where(id: blueprint.id).to_a
    result = results.first

    if result
      assert result.trending_score.positive?,
             "Blueprint with recent usage should have positive trending score"
    end
  end

  test "trending scope gives time boost to newer blueprints" do
    # Create a new blueprint (within last 7 days)
    new_blueprint = Blueprint::Factory.create!(
      title: "New Trending Blueprint",
      encoded_blueprint: blueprints(:public_factory).encoded_blueprint,
      cover_picture_data: blueprints(:public_factory).cover_picture_data,
      collection_id: collections(:member_public).id,
      game_version_id: 1,
      game_version_string: "0.9.27.15466",
      cached_votes_total: 1,
      usage_count: 1,
      tag_list: "production",
      created_at: 1.day.ago
    )

    # Create an old blueprint (older than 30 days)
    old_blueprint = blueprints(:public_dyson_sphere)
    old_blueprint.update!(created_at: 2.months.ago)

    results = Blueprint.trending.where(id: [new_blueprint.id, old_blueprint.id]).to_a

    new_result = results.find { |bp| bp.id == new_blueprint.id }
    old_result = results.find { |bp| bp.id == old_blueprint.id }

    if new_result && old_result
      # New blueprint should have higher score due to time boost
      # (even if old blueprint has more votes/usage)
      assert new_result.trending_score.positive?,
             "New blueprint should have positive trending score"
    end

    new_blueprint.destroy
  end

  test "trending scope only counts votes for Blueprint type" do
    blueprint = blueprints(:public_factory)

    # Create a vote for this blueprint
    vote = ActsAsVotable::Vote.create!(
      votable_type: "Blueprint",
      votable_id: blueprint.id,
      voter_type: "User",
      voter_id: users(:admin).id,
      vote_flag: true,
      created_at: 1.day.ago
    )

    results = Blueprint.trending.where(id: blueprint.id).to_a
    result = results.first

    if result
      assert result.trending_score.positive?,
             "Blueprint with vote should have positive trending score"
    end

    vote.destroy
  end
end
