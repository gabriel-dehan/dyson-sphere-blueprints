require 'benchmark'

class BlueprintParserJob < ApplicationJob
  queue_as :default

  def perform(blueprint_id)
    blueprint = Blueprint.find(blueprint_id)
    if blueprint.mod.name === "MultiBuildBeta"
      MultibuildBetaBlueprintParser::parse(blueprint, validate: false)
    end
  end
end
