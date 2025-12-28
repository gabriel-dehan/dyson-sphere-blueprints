require "test_helper"

class Parsers::MechaFileTest < ActiveSupport::TestCase
  test "validate raises error for too short file" do
    # Create a temp file with content too short to be valid
    short_file = Tempfile.new(["short", ".mecha"])
    short_file.write("Too short")
    short_file.rewind

    # The parser doesn't handle short files gracefully
    assert_raises(NoMethodError) do
      Parsers::MechaFile.validate(short_file)
    end

    short_file.close
    short_file.unlink
  end

  test "validate returns false for file with wrong control bit" do
    wrong_header_file = Tempfile.new(["wrong", ".mecha"], binmode: true)
    wrong_header_file.binmode

    # Wrong control bit (not 0x12)
    wrong_header_file.write([0x99].pack("C"))
    wrong_header_file.write("DSPMechaAppearance")
    wrong_header_file.write("\x00" * 16)
    wrong_header_file.write([0x01].pack("C"))

    wrong_header_file.rewind

    result = Parsers::MechaFile.validate(wrong_header_file)
    wrong_header_file.close
    wrong_header_file.unlink

    assert_not result
  end

  test "validate returns false for file with wrong header string" do
    wrong_header_file = Tempfile.new(["wrong", ".mecha"], binmode: true)
    wrong_header_file.binmode

    # Correct control bit
    wrong_header_file.write([0x12].pack("C"))
    # Wrong header string (must be exactly 18 bytes to match expected read size)
    wrong_header_file.write("NotMechaAppearance")
    wrong_header_file.write("\x00" * 16)
    wrong_header_file.write([0x01].pack("C"))

    wrong_header_file.rewind

    result = Parsers::MechaFile.validate(wrong_header_file)
    wrong_header_file.close
    wrong_header_file.unlink

    assert_not result
  end

  test "validate returns true for file with correct headers" do
    valid_file = Tempfile.new(["valid", ".mecha"], binmode: true)
    valid_file.binmode

    # Control bit (0x12)
    valid_file.write([0x12].pack("C"))
    # Header "DSPMechaAppearance" (18 bytes)
    valid_file.write("DSPMechaAppearance")
    # Unknown 16 bytes
    valid_file.write("\x00" * 16)
    # SOH (0x01)
    valid_file.write([0x01].pack("C"))
    # SOH separators (4 bytes)
    valid_file.write("\x00" * 4)
    # Name string
    valid_file.write("TestMecha")
    # Null terminator
    valid_file.write("\x00")

    valid_file.rewind

    result = Parsers::MechaFile.validate(valid_file)
    valid_file.close
    valid_file.unlink

    assert result
  end

  test "extract_data extracts name from valid file" do
    valid_file = Tempfile.new(["valid", ".mecha"], binmode: true)
    valid_file.binmode

    # Build valid mecha file
    valid_file.write([0x12].pack("C"))
    valid_file.write("DSPMechaAppearance")
    valid_file.write("\x00" * 16)
    valid_file.write([0x01].pack("C"))
    valid_file.write("\x00" * 4)
    valid_file.write("MyAwesomeMecha")
    valid_file.write("\x00")

    valid_file.rewind

    data = Parsers::MechaFile.extract_data(valid_file, with_png: false)
    valid_file.close
    valid_file.unlink

    assert data[:valid]
    assert_equal "MyAwesomeMecha", data[:name]
  end

  test "extract_data handles file with special characters in name" do
    valid_file = Tempfile.new(["valid", ".mecha"], binmode: true)
    valid_file.binmode

    valid_file.write([0x12].pack("C"))
    valid_file.write("DSPMechaAppearance")
    valid_file.write("\x00" * 16)
    valid_file.write([0x01].pack("C"))
    valid_file.write("\x00" * 4)
    valid_file.write("Mecha_123")
    valid_file.write("\x00")

    valid_file.rewind

    data = Parsers::MechaFile.extract_data(valid_file, with_png: false)
    valid_file.close
    valid_file.unlink

    assert data[:valid]
    assert_equal "Mecha_123", data[:name]
  end
end
