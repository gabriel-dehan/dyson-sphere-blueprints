class Parsers::DysonSphereProgramBlueprint
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
  end

  private

  def extract_blueprint_data(encoded_blueprint)
  end

  def extract_data(json)
  end

  private

  def basicSummary(dataExtract, entity)
  end

  def buildingSummary(dataExtract, entity)
  end
end