module Parsers
  class MechaFile
    class << self
      def validate(file)
        validate_headers(file)
      end

      def extract_data(file, with_png: true)
        control_bit = file.read(1).unpack1("C") # 0x12
        header = file.read(18)
        unknown = file.read(16) # 16 bytes, mostly EOSes
        soh = file.read(1).unpack1("C") # Start Of Heading
        soh_separators = file.read(4)
        name = ""

        loop do
          char = file.read(1)
          if char.unpack1("C") == 0x00
            break
          else
            name << char
          end
        end

        file.rewind

        valid = control_bit == 0x12 && header == "DSPMechaAppearance" && soh == 0x01

        if valid
          {
            name: name,
            image_b64: with_png ? generate_base64_image(file) : nil,
            valid: valid,
          }
        else
          {
            name: '',
            image_b64: nil,
            valid: valid,
          }
        end
      end

      def generate_base64_image(file)
        b64 = PngExtractor.extract_as_base64(file)
        file.rewind
        b64
      end

      def generate_png(file)
        image_file = PngExtractor.extract(file, nil, tmp: true)
        file.rewind
        image_file
      end

      private

      def validate_headers(file)
        control_bit = file.read(1).unpack1("C") # 0x12
        header = file.read(18)
        unknown = file.read(16) # 16 bytes, mostly EOSes
        soh = file.read(1).unpack1("C") # Start Of Heading, should be at byte 36

        control_bit == 0x12 && header == "DSPMechaAppearance" && soh == 0x01
      end
    end
  end
end
