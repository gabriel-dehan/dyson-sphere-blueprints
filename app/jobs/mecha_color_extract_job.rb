require "benchmark"

class MechaColorExtractJob < ApplicationJob
  queue_as :default

  def perform(blueprint_id)
    blueprint = Blueprint::Mecha.find(blueprint_id)
    Parsers::MechaBlueprint.new(blueprint).parse_colors!
  end
end
