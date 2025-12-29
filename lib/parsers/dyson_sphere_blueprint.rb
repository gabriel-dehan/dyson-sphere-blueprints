module Parsers
  class DysonSphereBlueprint
    # @param [Blueprint]
    def initialize(blueprint)
      @blueprint = blueprint
      @version = blueprint.game_version_string
    end

    # DYBP:0,637783100277796003,0.9.24.11192,4,0"H4sIAAAAAAA...
    # DYBP:0,637782832173123087,0.9.24.11192,1,90"H4sIAAAAAA...
    def validate
      Rails.logger.debug "Validating dyson sphere blueprint..."
      # TODO: Real validation
      @blueprint.encoded_blueprint.match(/\ADYBP:\d,(\d+,)+(\d+\.)+\d+,\d+,\d+".+/i)
    end

    def parse!(silent_errors: true)
      Rails.logger.info "Analyzing blueprint... #{@blueprint.id}"
      begin
        # TODO:
        # @blueprint.summary = data
        # @blueprint.save!
        Rails.logger.info "Done parsing blueprint #{@blueprint.id}"
      rescue StandardError => e
        if silent_errors
          Rails.logger.error "Couldn't decode blueprint: #{e.message}"
        else
          raise "Couldn't decode blueprint: #{e.message}"
        end
        nil
      end
    end
  end
end
