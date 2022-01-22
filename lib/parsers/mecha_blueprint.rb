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

    def validate
      puts "Validating factory blueprint..."
      # TODO: Validation
      false
    end

    def parse!(silent_errors: true)
      puts "Analyzing mecha blueprint... #{@blueprint.id}"
      begin
        # TODO:
        # @blueprint.summary = data
        # @blueprint.save!
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

    def generate_base64_image
      PNGExtractor.extract_as_base64(@blueprint_file)
    end

    def generate_png
      PNGExtractor.extract(@blueprint_file, nil, tmp: true)
    end
  end
end
