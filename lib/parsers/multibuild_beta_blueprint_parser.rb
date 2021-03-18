class MultibuildBetaBlueprintParser
  class << self
    def parse_version_207(blueprint)
      puts "Fetching blueprint..."
      begin
        first_pass = Base64.decode64(blueprint.encoded_blueprint)
        puts "Unzipping..."
        decoded_blueprint = ActiveSupport::Gzip.decompress(first_pass)
      rescue
        puts "Couldn't decode blueprint."
        return nil
      end
      json = JSON.parse(decoded_blueprint)
      ap json
      puts "Parsing..."
      buildingsData = json["copiedBuildings"].map { |building| building["protoId"] }
      insertersData = json["copiedInserters"].map { |inserter| inserter["protoId"] }
      beltsData = json["copiedBelts"].map { |belts| belts["protoId"] }

      blueprint.decoded_blueprint_data = {
        buildings: buildingsData.tally,
        inserters: insertersData.tally,
        belts: beltsData.tally,
      }

      puts "Saving..."
      blueprint.save!

      puts "Done!"
    end

    def parse_version_206(blueprint)
      puts "Fetching blueprint..."
      begin
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
end