require "test_helper"

class ColorTest < ActiveSupport::TestCase
  test "to_hex returns hex color string" do
    color = Color.new(r: 255, g: 0, b: 0, h: 0, s: 100, l: 50)
    assert_equal "#ff0000", color.to_hex
  end

  test "to_hex works for various colors" do
    # Green
    green = Color.new(r: 0, g: 128, b: 0, h: 120, s: 100, l: 25)
    assert_equal "#008000", green.to_hex

    # Blue
    blue = Color.new(r: 0, g: 0, b: 255, h: 240, s: 100, l: 50)
    assert_equal "#0000ff", blue.to_hex

    # White
    white = Color.new(r: 255, g: 255, b: 255, h: 0, s: 0, l: 100)
    assert_equal "#ffffff", white.to_hex

    # Black
    black = Color.new(r: 0, g: 0, b: 0, h: 0, s: 0, l: 0)
    assert_equal "#000000", black.to_hex
  end

  test "find_color_name sets exact match for known color" do
    # Pure red - exact match in COLOR_NAMES
    color = Color.new(r: 255, g: 0, b: 0, h: 0, s: 100, l: 50)
    color.save!

    # Name is stored as a string representation
    assert_equal "[:red]", color.name
  end

  test "find_color_name finds closest match for unknown color" do
    # A color close to red but not exactly red
    color = Color.new(r: 250, g: 5, b: 10, h: 0, s: 98, l: 50)
    color.save!

    # Should find a close color name (stored as string)
    # When closest is used, it returns a plain symbol which is converted to string
    assert_not_nil color.name
    assert color.name.is_a?(String)
    # Name should be a valid color name (may be with or without colon prefix)
    assert color.name.length > 0
  end

  test "decide returns array with exact match key" do
    color = Color.new(r: 0, g: 0, b: 255, h: 240, s: 100, l: 50)

    # Use send to access private method for testing
    result = color.send(:decide, Camalian::Color.new(0, 0, 255))

    assert_equal [:blue], result
  end

  test "closest finds nearest color when no exact match" do
    color = Color.new(r: 200, g: 100, b: 100, h: 0, s: 50, l: 60)

    # Create a color that's close to indianred (205, 92, 92) or rosybrown (188, 143, 143)
    camalian_color = Camalian::Color.new(200, 100, 100)
    result = color.send(:closest, camalian_color)

    # Should return a symbol (color name)
    assert result.is_a?(Symbol)
    assert_not_equal :undefined, result
  end

  test "before_create callback sets name" do
    # Gray (128, 128, 128) - exact match, but gray and grey are both matches
    color = Color.new(r: 128, g: 128, b: 128, h: 0, s: 0, l: 50)

    assert_nil color.name

    color.save!

    assert_not_nil color.name
    # Should contain either :gray or :grey (both are 128,128,128)
    assert color.name.include?(":gray") || color.name.include?(":grey")
  end
end
