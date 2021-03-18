require 'benchmark'

class BlueprintParserJob < ApplicationJob
  queue_as :default

  def perform(blueprint_id)
    blueprint = Blueprint.find(blueprint_id)
    if blueprint.mod.name === "MultiBuildBeta"
      if blueprint.mod_version <= "2.0.6"
        MultibuildBetaBlueprintParser::parse_version_206(blueprint)
      else
        MultibuildBetaBlueprintParser::parse_version_207(blueprint)
      end
    end
  end
end
