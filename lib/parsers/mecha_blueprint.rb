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

  end
end
