module Parsers
  class MechaBlueprint
    # @param [Blueprint]
    def initialize(blueprint)
      @blueprint = blueprint
      @version = blueprint.mod_version

      @blueprint_file = @blueprint.blueprint_file.download
      @blueprint_binary_data = @blueprint_file.read

      @blueprint_file.rewind
    end

    def parse!(silent_errors: true)
      puts "Analyzing mecha blueprint... #{@blueprint.id}"
      begin
        preview_file = Parsers::MechaFile.generate_png(@blueprint_file)
        @blueprint.cover_picture = preview_file.open

        data = Parsers::MechaFile.extract_data(@blueprint_file)

        @blueprint.summary = {
          name: data[:name],
        }
        @blueprint.save!
        puts "Done!"
      rescue StandardError => e
        if silent_errors
          puts "Couldn't decode blueprint: #{e.message}"
        else
          raise "Couldn't decode blueprint: #{e.message}"
        end
        nil
      end
    end

    def parse_colors!(silent_errors: true)
      puts "Analyzing mecha color data... #{@blueprint.id}"
      begin
        image = Parsers::MechaFile.generate_png(@blueprint_file)
        image.open
        color_tool = Camalian::load(image.path)
        colors = color_tool.prominent_colors(24, quantization: Camalian::QUANTIZATION_K_MEANS)

        summary = @blueprint.summary
        summary[:color_profile] = {
          colors_by_hue: colors.sort_by_hue,
          colors_light: colors.sort_by_hue.light_colors(50, 120),
          colors_by_similarity: colors.sort_similar_colors,
          colors_by_lightness: colors.sort_by_lightness,
          colors_by_saturation: colors.sort_by_saturation,
        }
        @blueprint.summary = summary

        @blueprint.colors = colors.sort_by_hue.map do |extracted_color|
          Color.find_or_create_by!(r: extracted_color.r, g: extracted_color.g, b: extracted_color.b, h: extracted_color.h, s: extracted_color.s, l: extracted_color.l)
        end

        @blueprint.save!
        puts "Done!"
      rescue StandardError => e
        if silent_errors
          puts "Couldn't decode blueprint: #{e.message}"
        else
          raise "Couldn't decode blueprint: #{e.message}"
        end
        nil
      end
    end
  end
end
