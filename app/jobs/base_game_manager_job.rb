class BaseGameManagerJob < ApplicationJob
  queue_as :default

  def perform(patch)
    mod_data = {
      "name"  => "Dyson Sphere Program",
      "owner" => "Youthcat Studio",
      "uuid4" => "dyson-sphere-program",
    }
    Rails.logger.info "Starting base game version update"

    Rails.logger.info "Updating Dyson Sphere Program..."
    mod = Mod.find_by(uuid4: mod_data["uuid4"])
    # Create the mod in DB if it's not registered
    mod = Mod.create!(name: mod_data["name"], author: mod_data["owner"], uuid4: mod_data["uuid4"], versions: {}) if !mod

    date = Time.zone.now
    registered_versions = mod.versions

    if patch
      unregistered_versions = [patch]
    else
      Rails.logger.info "Fetching base game versions..."
      # TODO: Actually fetch from steam API or something
      api_url = URI("https://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=1366540&count=5&maxlength=300&format=json")
      response = Net::HTTP.get(api_url)

      if response&.present?
        mod_list = JSON.parse(response)
        fetched_patches = mod_list["appnews"]["newsitems"].reverse.map do |news|
          match = news["title"].match(/Patch Notes V?(\d+\.\d+\.\d+\.\d+)|\[Version (\d+\.\d+\.\d+\.\d+)\]|Version (\d+\.\d+\.\d+\.\d+)/i).to_a.compact
          match ? match[1] : nil
        end
        unregistered_versions = fetched_patches.filter { |fetched_patch| !registered_versions[fetched_patch] }
      else
        Rails.logger.error "Couldn't get a response from Steam API. Terminating."
        return nil
      end
    end

    unregistered_versions.each do |unregistered_version|
      version = {
        "version_number" => unregistered_version,
        "uuid4"          => "#{unregistered_version}-#{date.to_i}",
      }

      Rails.logger.info "Registering new version #{version['version_number']}"
      if registered_versions[version["version_number"]]
        Rails.logger.warn "Version already exists!"
      else
        registered_versions[version["version_number"]] = {
          uuid4: version["uuid4"],
          breaking: false,
          created_at: date,
        }

        # Update the model
        mod.update!(versions: registered_versions)
      end
    end

    Rails.logger.info "Done updating base game versions"
  end
end
