require "test_helper"

class GameVersionTest < ActiveSupport::TestCase
  # ============================================
  # VERSION LIST TESTS
  # ============================================

  test "latest returns first version from version_list" do
    game_version = game_versions(:dsp)
    # version_list is sorted DESC using semantic versioning (Gem::Version)
    assert_equal game_version.version_list.first, game_version.latest
    # With semantic sorting, 0.10.x > 0.9.x
    assert_equal "0.10.30.22292", game_version.latest
  end

  test "latest_breaking returns most recent breaking version" do
    game_version = game_versions(:dsp)
    # Should return the most recent breaking version using semantic sorting
    # 0.10.30.22292 is breaking and newer than 0.9.27.15466
    assert_equal "0.10.30.22292", game_version.latest_breaking
  end

  test "version_list returns sorted versions descending by semantic version" do
    game_version = game_versions(:dsp)
    list = game_version.version_list

    assert_kind_of Array, list
    assert_equal 4, list.length
    # Should be sorted descending by Gem::Version (semantic versioning)
    expected_order = ["0.10.30.22292", "0.10.29.22015", "0.9.27.15466", "0.9.24.11286"]
    assert_equal expected_order, list
  end

  # ============================================
  # COMPATIBILITY RANGE TESTS
  # ============================================
  #
  # Fixture versions (semantic order, ascending):
  #   0.9.24.11286  (breaking: false)
  #   0.9.27.15466  (breaking: true)
  #   0.10.29.22015 (breaking: false)
  #   0.10.30.22292 (breaking: true)

  test "compatibility_range_for returns range array with two elements" do
    game_version = game_versions(:dsp)
    range = game_version.compatibility_range_for("0.9.27.15466")

    assert_kind_of Array, range
    assert_equal 2, range.length
    assert game_version.version_list.include?(range.first), "First element should be a valid version"
    assert game_version.version_list.include?(range.last), "Last element should be a valid version"
  end

  test "compatibility_range_for version before any breaking change" do
    game_version = game_versions(:dsp)
    # 0.9.24.11286 is before the first breaking version (0.9.27.15466)
    range = game_version.compatibility_range_for("0.9.24.11286")

    # Should be compatible from itself up to before the next breaking version
    assert_equal "0.9.24.11286", range.first
    assert_equal "0.10.30.22292", range.last
  end

  test "compatibility_range_for version at a breaking change" do
    game_version = game_versions(:dsp)
    # 0.9.27.15466 is a breaking version
    range = game_version.compatibility_range_for("0.9.27.15466")

    # Range starts at this breaking version, ends just before next breaking version
    assert_equal "0.9.27.15466", range.first
    assert_equal "0.10.29.22015", range.last
  end

  test "compatibility_range_for version between breaking changes" do
    game_version = game_versions(:dsp)
    # 0.10.29.22015 is between breaking versions 0.9.27.15466 and 0.10.30.22292
    range = game_version.compatibility_range_for("0.10.29.22015")

    # Range starts at previous breaking version, ends at this version (before next breaking)
    assert_equal "0.9.27.15466", range.first
    assert_equal "0.10.29.22015", range.last
  end

  test "compatibility_range_for version at latest breaking change" do
    game_version = game_versions(:dsp)
    # 0.10.30.22292 is the latest breaking version
    range = game_version.compatibility_range_for("0.10.30.22292")

    # Only compatible with itself since it's the latest and breaking
    assert_equal "0.10.30.22292", range.first
    assert_equal "0.10.30.22292", range.last
  end

  test "compatibility_range_for uses semantic versioning not string comparison" do
    game_version = game_versions(:dsp)
    # This test ensures 0.10.x is correctly treated as newer than 0.9.x
    range = game_version.compatibility_range_for("0.10.29.22015")

    # With correct semantic sorting, 0.9.27.15466 < 0.10.29.22015 < 0.10.30.22292
    # String sorting would incorrectly order these
    assert_equal "0.9.27.15466", range.first
    assert_equal "0.10.29.22015", range.last
  end

  # ============================================
  # COMPATIBILITY LIST TESTS
  # ============================================

  test "compatibility_list_for returns versions within range" do
    game_version = game_versions(:dsp)
    list = game_version.compatibility_list_for("0.9.27.15466")

    # Should return versions in the range [0.9.27.15466, 0.10.29.22015]
    assert_kind_of Array, list
    assert_includes list, "0.9.27.15466"
    assert_includes list, "0.10.29.22015"
    assert_not_includes list, "0.9.24.11286"   # Before range
    assert_not_includes list, "0.10.30.22292"  # After range (next breaking)
  end

  test "compatibility_list_for returns versions sorted by semantic version" do
    game_version = game_versions(:dsp)
    list = game_version.compatibility_list_for("0.9.27.15466")

    # Should be sorted ascending by semantic version
    expected = ["0.9.27.15466", "0.10.29.22015"]
    assert_equal expected, list
  end

  # ============================================
  # HELPER METHODS
  # ============================================

  test "to_select returns array for select options" do
    options = GameVersion.to_select

    assert_kind_of Array, options
    assert options.any? { |opt| opt[0] == "Dyson Sphere Program" }
  end
end
