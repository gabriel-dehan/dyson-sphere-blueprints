module Parsers
  class DysonSphereBlueprint
    # @param [Blueprint]
    def initialize(blueprint)
      @blueprint = blueprint
      @version = blueprint.mod_version
    end

    # DYBP:0,637783100277796003,0.9.24.11192,4,0"H4sIAAAAAAA...
    # DYBP:0,637782832173123087,0.9.24.11192,1,90"H4sIAAAAAA...
    def validate
      puts "Validating factory blueprint..."
      # TODO: Real validation
      @blueprint.encoded_blueprint.match(/\ADYBP:\d,(\d+,)+(\d+\.)+\d+,\d+,\d+".+/i)
    end

    def parse!(silent_errors: true)
      puts "Analyzing blueprint... #{@blueprint.id}"
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
  end
end
