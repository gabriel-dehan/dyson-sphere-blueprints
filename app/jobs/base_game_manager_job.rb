class BaseGameManagerJob < ApplicationJob
  queue_as :default

  def perform(patch)
    puts "Fetching ba game versions..."
    # TODO: Actually fetch from steam API or something
    mod_data = {
      "name"  => "Dyson Sphere Program",
      "owner" => "Youthcat Studio",
      "uuid4" => "dyson-sphere-program"
    }
    puts "Fetched mods!"

    puts "Updating Dyson Sphere Blueprint..."
    mod = Mod.find_by(uuid4: mod_data["uuid4"])
    # Create the mod in DB if it's not registered
    if !mod
      mod = Mod.create!(name: mod_data["name"], author: mod_data["owner"], uuid4: mod_data["uuid4"], versions: {})
    end

    date = Time.now
    registered_versions = mod.versions
    version = {
      "version_number" => patch,
      "uuid4" => "#{patch}-#{date.to_i}"
    }

    puts "Registering new version #{version['version_number']}"
    if !registered_versions[version["version_number"]]
      registered_versions[version["version_number"]] = {
        uuid4: version["uuid4"],
        breaking: false,
        created_at: date
      }

      # Update the model
      mod.update!(versions: registered_versions)
    else
      puts "Version already exists!"
    end

    puts "Done!"
  end
end