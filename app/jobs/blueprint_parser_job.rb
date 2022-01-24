require "benchmark"

class BlueprintParserJob < ApplicationJob
  queue_as :default

  def perform(blueprint_id)
    blueprint = Blueprint.find(blueprint_id)

    if blueprint.mod.name == "MultiBuildBeta"
      Parsers::MultibuildBetaBlueprint.new(blueprint).parse!
    elsif blueprint.mod.name == "MultiBuild"
      Parsers::MultibuildBetaBlueprint.new(blueprint).parse!
    elsif blueprint.mod.name == "Dyson Sphere Program"
      # Handle 3 different blueprint types
      if blueprint.type == "Dyson Sphere"
        Parsers::DysonSphereBlueprint.new(blueprint).parse!
      elsif blueprint.type == "Mecha"
        Parsers::MechaBlueprint.new(blueprint).parse!
      else # Factory
        Parsers::FactoryBlueprint.new(blueprint).parse!
      end
    end
  end
end
