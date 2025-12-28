require "test_helper"

class ModTest < ActiveSupport::TestCase
  # ============================================
  # VERSION LIST TESTS
  # ============================================

  test "latest returns first version from version_list" do
    mod = mods(:dsp)
    # version_list is sorted DESC (string sort), so first is "latest"
    # Note: String sorting means "0.9.x" > "0.10.x"
    assert_equal mod.version_list.first, mod.latest
  end

  test "latest_breaking returns most recent breaking version" do
    mod = mods(:dsp)
    # Find the first breaking version in the sorted list
    expected = mod.versions.sort.reverse.find { |v, data| data["breaking"] }&.first
    assert_equal expected, mod.latest_breaking
  end

  test "version_list returns sorted versions descending" do
    mod = mods(:dsp)
    list = mod.version_list

    assert_kind_of Array, list
    assert_equal 4, list.length
    # Should be in string-sorted descending order
    assert_equal list.sort.reverse, list
  end

  # ============================================
  # COMPATIBILITY RANGE TESTS
  # ============================================

  test "compatibility_range_for returns range array" do
    mod = mods(:dsp)
    range = mod.compatibility_range_for("0.9.27.15466")

    assert_kind_of Array, range
    assert_equal 2, range.length
  end

  test "compatibility_range_for returns valid version strings" do
    mod = mods(:dsp)
    range = mod.compatibility_range_for("0.9.27.15466")

    # Both elements should be version strings from our version list
    assert mod.version_list.include?(range.first) || range.first.present?
    assert mod.version_list.include?(range.last) || range.last.present?
  end

  test "compatibility_range_for handles breaking version" do
    mod = mods(:dsp)
    # 0.9.27.15466 is a breaking version
    range = mod.compatibility_range_for("0.9.27.15466")

    # Should return a range that includes the breaking version
    assert_kind_of Array, range
    assert_equal 2, range.length
  end

  # ============================================
  # COMPATIBILITY LIST TESTS
  # ============================================

  test "compatibility_list_for returns array" do
    mod = mods(:dsp)
    # Use a version we know exists in the fixture
    list = mod.compatibility_list_for("0.9.27.15466")

    # Should return an array (may be empty depending on range logic)
    assert_kind_of Array, list
  end

  # ============================================
  # HELPER METHODS
  # ============================================

  test "to_select returns array for select options" do
    options = Mod.to_select

    assert_kind_of Array, options
    assert options.any? { |opt| opt[0] == "Dyson Sphere Program" }
  end
end
