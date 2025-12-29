require "benchmark"

class BlueprintParserJob < ApplicationJob
  queue_as :default

  def perform(blueprint_id)
    blueprint = Blueprint.find(blueprint_id)

    case blueprint.type
    when "DysonSphere"
      Parsers::DysonSphereBlueprint.new(blueprint).parse!
    when "Mecha"
      Parsers::MechaBlueprint.new(blueprint).parse!
    else # Factory
      Parsers::FactoryBlueprint.new(blueprint).parse!
    end
  end
end
