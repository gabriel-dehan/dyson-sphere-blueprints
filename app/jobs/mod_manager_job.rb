class ModManagerJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    puts "Fetching mod list..."
    api_url = URI("https://dsp.thunderstore.io/api/v1/package/")
    response = Net::HTTP.get(api_url)
    if response&.present?
      puts "Fetched mods!"
      mod_list = JSON.parse(response)

      Mod::MANAGED_MODS.each do |mod_name|
        puts "Updating #{mod_name}..."
        mod_data = parse_mod_data(mod_name, mod_list)
        mod = Mod.find_by(uuid4: mod_data["uuid4"])
        # Create the mod in DB if it's not registered
        mod = Mod.create!(name: mod_data["name"], author: mod_data["owner"], uuid4: mod_data["uuid4"], versions: {}) if !mod

        registered_versions = mod.versions

        # Find new version and add them to the list
        mod_data["versions"].each do |version|
          next if registered_versions[version["version_number"]]
          # Only MultiBuild >= 2.2.0
          next unless mod.name == "MultiBuildBeta" || (mod.name == "MultiBuild" && version["version_number"] >= "2.2.0")

          puts "Registering new mod version #{version['version_number']}"
          registered_versions[version["version_number"]] = {
            uuid4: version["uuid4"],
            breaking: false,
            created_at: version["date_created"],
          }
        end

        # Update the model
        mod.update!(versions: registered_versions)

        puts "Done!"
      end
    end
  end

  def parse_mod_data(mod_name, mod_list)
    mod_list.find { |mod| mod["name"] == mod_name }
  end
end
