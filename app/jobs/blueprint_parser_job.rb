require 'benchmark'

class BlueprintParserJob < ApplicationJob
  queue_as :default

  def perform(blueprint_id)
    blueprint = Blueprint.find(blueprint_id)
    if blueprint.mod.name === "MultiBuildBeta"
      Parsers::MultibuildBetaBlueprint.new(blueprint).parse!
    end
  end
end
