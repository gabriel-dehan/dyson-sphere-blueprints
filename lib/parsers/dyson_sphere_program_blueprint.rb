module Parsers
  class DysonSphereProgramBlueprint
    # @param [Blueprint]
    def initialize(blueprint)
      @blueprint = blueprint
      @version = blueprint.mod_version
    end

    def validate
      puts "Validating blueprint..."
      # TODO: Real validation
      @blueprint.encoded_blueprint.match(/\ABLUEPRINT:\d,(\d+,){6}\d+,\d+,(\d+\.?)+,.+,.+/i)
    end

    def parse!(silent_errors: true)
      puts "Analyzing blueprint..."
      begin
        @blueprint_data = DspBlueprintParser.parse(@blueprint.encoded_blueprint)
        raise "No data found in blueprint" if !@blueprint_data || @blueprint_data.buildings.size.zero?

        data = { buildings: {}, inserters: {}, belts: {} }
        @blueprint_data.buildings.reduce(data) { |res, entity| building_summary(res, entity) }
        @blueprint.summary = data

        puts "Saving..."
        @blueprint.save!

        puts "Done!"
      rescue StandardError => e
        if silent_errors
          puts "Couldn't decode blueprint: #{e.message}"
        else
          raise "Couldn't decode blueprint: #{e.message}"
        end
        return nil
      end
    end

    private

    # @param entity [DspBlueprintParser::Building]
    def building_summary(data_extract, entity)
      entities_engine = Engine::Entities.instance
      recipes_engine = Engine::Recipes.instance
      proto_id = entity.item_id
      recipe_id = entity.recipe_id

      key = :buildings
      key = :belts if entities_engine.is_belt?(proto_id)
      key = :inserters if entities_engine.is_sorter?(proto_id)

      data_extract[key][proto_id] ||= { tally: 0 }
      data_extract[key][proto_id][:recipes] ||= {}
      data_extract[key][proto_id][:name] ||= entities_engine.get_name(proto_id)
      data_extract[key][proto_id][:tally] += 1

      if recipe_id.positive?
        data_extract[key][proto_id][:recipes][recipe_id] ||= { tally: 0 }
        data_extract[key][proto_id][:recipes][recipe_id][:name] ||= recipes_engine.get_name(recipe_id)
        data_extract[key][proto_id][:recipes][recipe_id][:tally] += 1
      end

      data_extract
    end
  end
end
