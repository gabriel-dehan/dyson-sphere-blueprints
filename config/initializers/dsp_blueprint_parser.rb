# dsp_blueprint_parser 0.2.3 does not consume the content field appended to
# version -102 building records. Remove this compatibility patch after upgrading
# to a parser release that handles the field itself.
module DspBlueprintParser
  class BinaryReader
    def skip_dotnet_string
      byte_length = 0
      shift = 0

      loop do
        byte = read_i8 & 0xff
        byte_length |= (byte & 0x7f) << shift
        break if (byte & 0x80).zero?

        shift += 7
        raise "Invalid string length" if shift >= 35
      end

      new_position = @position + byte_length
      raise "Unexpected end of blueprint data" if new_position > @data.length

      @position = new_position
    end
  end

  class BuildingParser
    class << self
      alias_method :path_102_without_content, :path_102

      def path_102(reader)
        building = path_102_without_content(reader)
        reader.skip_dotnet_string if reader.read_i32.positive?
        building
      end

      private :path_102
    end
  end
end
