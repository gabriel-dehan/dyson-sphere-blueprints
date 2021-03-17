require 'benchmark'

class BlueprintParserJob < ApplicationJob
  queue_as :default

  def perform(blueprint_id)
    puts "Fetching blueprint..."
    begin
      blueprint = Blueprint.find(blueprint_id)
      first_pass = Base64.decode64(blueprint.encoded_blueprint)
      puts "Unzipping..."
      decoded_blueprint = ActiveSupport::Gzip.decompress(first_pass)
    rescue
      puts "Couldn't decode blueprint."
      return nil
    end
    json = JSON.parse(decoded_blueprint)

    puts "Parsing..."
    buildingsData = json["copiedBuildings"].map { |building| building["Value"]["protoId"] }
    insertersData = json["copiedInserters"].map { |inserter| inserter["Value"]["protoId"] }
    beltsData = json["copiedBelts"].map { |belts| belts["Value"]["protoId"] }

    blueprint.decoded_blueprint_data = {
      buildings: buildingsData.tally,
      inserters: insertersData.tally,
      belts: beltsData.tally,
    }

    puts "Saving..."
    blueprint.save!

    puts "Done!"
  end
end
