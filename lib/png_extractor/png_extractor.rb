require "base64"
require "securerandom"
require "tempfile"

# Extracts embedded PNG files from binary files
# https://www.w3.org/TR/PNG-Structure.html
# Inspired by: https://github.com/jomo/PNGExtract
#
# Example:
#
#   PNGExtractor.extract(
#     File.join(File.dirname(__FILE__), '..', '..', 'test.mecha'),
#     File.join(File.dirname(__FILE__), '..', '..', 'result.mecha')
#   )
#
#   OR
#
#   PNGExtractor.extract_as_base64(File.join(File.dirname(__FILE__), '..', '..', 'test.mecha'))
#
class PNGExtractor
  class NotFound < StandardError; end

  class << self
    def extract_as_base64(file, verbose: true)
      output_file = extract(file, nil, verbose: verbose, tmp: true)
      output_file.rewind

      base64_string = Base64.encode64(output_file.read)

      # Delete tmp file
      output_file.close
      output_file.unlink

      base64_string
    end

    # File should be in `rb` mode
    def extract(file, output_path, verbose: true, tmp: false)
      file_beginning = file.pos
      # Find PNG data in file
      png_data = Regexp.new("\211PNG".force_encoding("BINARY")).match(file.read)

      unless png_data
        verbose ? raise(PNGExtractor::NotFound("Could not find PNG data")) : false
      end

      png_data_position = png_data.begin(0)
      # Position cursor at the png_data_position
      file.seek(file_beginning + png_data_position)

      if tmp
        output_file = Tempfile.new(["#{File.basename(file.path.split('/').last)}-#{SecureRandom.uuid}", ".png"], binmode: true)
      else
        output_file = File.new("#{output_path}.png", "wb")
      end

      extract_png(file, output_file)

      output_file
    end

    private

    def extract_png(input, output)
      hdr = input.read(8)
      hex = hdr.unpack("C8")
      if hex != [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]
        puts "Not a PNG File: #{hex}"
        return
      end
      output.write(hdr)

      loop do
        chunk_type = extract_chunk(input, output)
        break if chunk_type.nil? || chunk_type == "IEND"
      end
    end

    def extract_chunk(input, output)
      lenword = input.read(4)
      length  = lenword.unpack1("N")
      type    = input.read(4)
      data    = length >= 0 ? input.read(length) : ""
      crc     = input.read(4)

      return nil if length < 0 || ("A".."z").exclude?(type[0, 1]) # rubocop:disable Style/NumericPredicate

      output.write lenword
      output.write type
      output.write data
      output.write crc
      type
    end
  end
end
