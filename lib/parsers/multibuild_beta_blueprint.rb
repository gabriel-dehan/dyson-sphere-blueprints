class Parsers::MultibuildBetaBlueprint
  def initialize(blueprint)
    @blueprint = blueprint
    @version = blueprint.mod_version
  end

  def validate
    puts "Validating blueprint..."
    begin
      json_data = extract_blueprint_data(@blueprint.encoded_blueprint)

      buildingsData = json_data["copiedBuildings"].map { |entity| get_key("protoId", entity) }
      insertersData = json_data["copiedInserters"].map { |entity| get_key("protoId", entity) }
      beltsData = json_data["copiedBelts"].map { |entity| get_key("protoId", entity) }

      !(buildingsData.compact.empty? && insertersData.compact.empty? && beltsData.compact.empty?)
    rescue StandardError
      puts "Blueprint invalid."
      false
    end
  end

  def parse!(silent_errors: true)
    puts "Analyzing blueprint..."
    begin
      json_data = extract_blueprint_data(@blueprint.encoded_blueprint)

      puts "Parsing..."
      has_data, data = extract_data(json_data)
      raise "No data found in blueprint" if !has_data

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
      nil
    end
  end

  private

  def extract_blueprint_data(encoded_blueprint)
    puts "Cleaning blueprint data..."
    # Blueprints can be prefixed with /\w+:/ so we remove the first part
    split_on_name = encoded_blueprint.split(":")
    if split_on_name.length > 1
      blueprint_without_name = split_on_name[1..].join(":")
    else
      blueprint_without_name = encoded_blueprint
    end

    puts "Decoding..."
    first_pass = Base64.decode64(blueprint_without_name)
    decoded_blueprint = ActiveSupport::Gzip.decompress(first_pass)
    JSON.parse(decoded_blueprint)
  end

  def extract_data(json)
    has_data = true

    buildingsData = json["copiedBuildings"].reduce({}) { |res, entity| buildingSummary(res, entity) }
    insertersData = json["copiedInserters"].reduce({}) { |res, entity| basicSummary(res, entity) }
    beltsData = json["copiedBelts"].reduce({}) { |res, entity| basicSummary(res, entity) }

    data = {
      buildings: buildingsData,
      inserters: insertersData,
      belts: beltsData,
    }

    if buildingsData.compact.empty? &&
       insertersData.compact.empty? &&
       beltsData.compact.empty?
      has_data = false
    end

    ap data

    [has_data, data]
  end

  def basicSummary(dataExtract, entity)
    entities_engine = Engine::Entities.instance
    protoId = get_key("protoId", entity)

    dataExtract[protoId] ||= { tally: 0 }

    dataExtract[protoId][:name] ||= entities_engine.get_name(protoId)
    dataExtract[protoId][:tally] += 1
    dataExtract
  end

  def buildingSummary(dataExtract, entity)
    entities_engine = Engine::Entities.instance
    recipes_engine = Engine::Recipes.instance
    protoId = get_key("protoId", entity)

    dataExtract = basicSummary(dataExtract, entity)

    if entities_engine.is_builder?(protoId)
      dataExtract[protoId][:recipes] ||= {}
      recipeId = get_key("recipeId", entity)

      if recipeId
        dataExtract[protoId][:recipes][recipeId] ||= { tally: 0 }
        dataExtract[protoId][:recipes][recipeId][:name] ||= recipes_engine.get_name(recipeId)
        dataExtract[protoId][:recipes][recipeId][:tally] += 1
      end
    end

    dataExtract
  end

  def get_key(key, entity)
    if @version <= "2.0.6"
      entity["Value"][key]
    else
      entity[key]
    end
  end
end
