module Parsers
  class FactoryBlueprint
    # @param [Blueprint]
    def initialize(blueprint)
      @blueprint = blueprint
      @version = blueprint.game_version_string
    end

    def validate
      Rails.logger.debug "Validating blueprint..."
      # TODO: Real validation
      @blueprint.encoded_blueprint.match(/\ABLUEPRINT:\d,(\d+,){6}\d+,\d+,(\d+\.?)+,.+,.+/i)
    end

    def parse!(silent_errors: true)
      Rails.logger.info "Analyzing blueprint... #{@blueprint.id}"
      begin
        @blueprint_data = DspBlueprintParser.parse(@blueprint.encoded_blueprint)
        raise "No data found in blueprint" if !@blueprint_data || @blueprint_data.buildings.size.zero?

        data = parse_blueprint_data
        @blueprint.summary = data

        Rails.logger.debug { "Saving blueprint #{@blueprint.id}..." }
        @blueprint.save!

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

    private

    def parse_blueprint_data
      Rails.logger.debug "Parsing blueprint data..."
      data = { total_structures: 0, buildings: {}, inserters: {}, belts: {} }
      @blueprint_data.buildings.reduce(data) { |res, entity| building_summary(res, entity) }
      # Set the current mass construction research depending on the total number of structures
      research_uuid = Engine::Researches::MASS_CONSTRUCTION_LIMITS.find { |_research, limit| data[:total_structures] <= limit }.first
      data[:research] = Engine::Researches.instance.get_name(research_uuid)
      data
    end

    # @param entity [DspBlueprintParser::Building]
    # Example summary:
    # {
    #   "total_structures" => 558,
    #   "buildings" => {
    #     "2104" => {
    #       "tally" => 1,
    #       "recipes" => {},
    #       "name" => "Interstellar Logistics Station"
    #     },
    #     "2201" => {
    #       "tally" => 8,
    #       "recipes" => {},
    #       "name" => "Tesla tower"
    #     },
    #     "2305" => {
    #       "tally" => 30,
    #       "recipes" => {
    #         "98" => {
    #           "tally" => 30,
    #           "name" => "Electromagnetic turbine"
    #         }
    #       },
    #       "name" => "Assembling machine Mk.III"
    #     }
    #   },
    #   "inserters" => {
    #     "2013" => {
    #       "tally" => 90,
    #       "name" => "Sorter MK.III"
    #     }
    #   },
    #   "belts" => {
    #     "2003" => {
    #       "tally" => 429,
    #       "name" => "Conveyor belt MK.III"
    #     }
    #   }
    # }
    def building_summary(data_extract, entity)
      entities_engine = Engine::Entities.instance
      recipes_engine  = Engine::Recipes.instance

      proto_id  = entity.item_id
      recipe_id = entity.recipe_id
      is_belt   = entities_engine.is_belt?(proto_id)
      is_sorter = entities_engine.is_sorter?(proto_id)
      is_building = !is_belt && !is_sorter

      key = :buildings
      key = :belts if is_belt
      key = :inserters if is_sorter

      data_extract[key][proto_id] ||= { tally: 0 }
      data_extract[key][proto_id][:recipes] ||= {} if is_building
      data_extract[key][proto_id][:name] ||= entities_engine.get_name(proto_id)
      data_extract[key][proto_id][:tally] += 1
      data_extract[:total_structures] += 1

      if recipe_id.positive?
        data_extract[key][proto_id][:recipes][recipe_id] ||= { tally: 0 }
        data_extract[key][proto_id][:recipes][recipe_id][:name] ||= recipes_engine.get_name(recipe_id)
        data_extract[key][proto_id][:recipes][recipe_id][:tally] += 1
      end

      data_extract
    end
  end
end
