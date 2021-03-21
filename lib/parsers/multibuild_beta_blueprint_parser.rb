class MultibuildBetaBlueprintParser
  class << self
    def parse(blueprint, validate = false)
      puts "Analyzing blueprint..."
      begin
        # Blueprints can be prefixed with /\w+:/ so we remove the first part
        split_on_name = blueprint.encoded_blueprint.split(":")
        if split_on_name.length > 1
          blueprint_without_name = split_on_name[1..-1].join(":")
        else
          blueprint_without_name = blueprint.encoded_blueprint
        end

        first_pass = Base64.decode64(blueprint_without_name)
        puts "Unzipping..."
        decoded_blueprint = ActiveSupport::Gzip.decompress(first_pass)

        json = JSON.parse(decoded_blueprint)
        puts "Parsing..."
        buildingsData, insertersData, beltsData = self.data_for(json, blueprint.mod_version)

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

    def data_for(json, version)
      if version <= "2.0.6"
        buildingsData = json["copiedBuildings"].map { |building| building["Value"]["protoId"] }
        insertersData = json["copiedInserters"].map { |inserter| inserter["Value"]["protoId"] }
        beltsData = json["copiedBelts"].map { |belts| belts["Value"]["protoId"] }
      else
        buildingsData = json["copiedBuildings"].map { |building| building["protoId"] }
        insertersData = json["copiedInserters"].map { |inserter| inserter["protoId"] }
        beltsData = json["copiedBelts"].map { |belts| belts["protoId"] }
      end

      [buildingsData, insertersData, beltsData]
    end
  end
end