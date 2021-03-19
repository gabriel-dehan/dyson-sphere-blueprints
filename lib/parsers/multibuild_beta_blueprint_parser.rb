class MultibuildBetaBlueprintParser
  class << self
    def parse_version_210(blueprint, validate = false)
      puts "Fetching blueprint for 210..."
      begin
        first_pass = Base64.decode64(blueprint.encoded_blueprint)
        puts "Unzipping..."
        decoded_blueprint = ActiveSupport::Gzip.decompress(first_pass)

        json = JSON.parse(decoded_blueprint)
        puts "Parsing..."
        buildingsData = json["copiedBuildings"].map { |building| building["protoId"] }
        insertersData = json["copiedInserters"].map { |inserter| inserter["protoId"] }
        beltsData = json["copiedBelts"].map { |belts| belts["protoId"] }

        if buildingsData.compact.length == 0 &&
          insertersData.compact.length == 0 &&
          beltsData.compact.length == 0
          raise "No data found in blueprint"
        end

        blueprint.decoded_blueprint_data = {
          buildings: buildingsData.tally,
          inserters: insertersData.tally,
          belts: beltsData.tally,
        }

        if validate
          return true
        else
          puts "Saving..."
          blueprint.save!

          puts "Done!"
        end
      rescue
        puts "Couldn't decode blueprint."
        return false
      end
    end

    def parse_version_206(blueprint, validate = false)
      puts "Fetching blueprint for 206..."
      begin
        first_pass = Base64.decode64(blueprint.encoded_blueprint)
        puts "Unzipping..."
        decoded_blueprint = ActiveSupport::Gzip.decompress(first_pass)

        json = JSON.parse(decoded_blueprint)

        puts "Parsing..."
        buildingsData = json["copiedBuildings"].map { |building| building["Value"]["protoId"] }
        insertersData = json["copiedInserters"].map { |inserter| inserter["Value"]["protoId"] }
        beltsData = json["copiedBelts"].map { |belts| belts["Value"]["protoId"] }

        if buildingsData.compact.length === 0 &&
          insertersData.compact.length === 0 &&
          beltsData.compact.length === 0
          raise "No data found in blueprint"
        end

        blueprint.decoded_blueprint_data = {
          buildings: buildingsData.tally,
          inserters: insertersData.tally,
          belts: beltsData.tally,
        }

        if validate
          return true
        else
          puts "Saving..."
          blueprint.save!

          puts "Done!"
        end
      rescue
        puts "Couldn't decode blueprint."
        return false
      end
    end
  end
end