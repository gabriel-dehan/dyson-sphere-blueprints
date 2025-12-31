namespace :power_data do
  desc "Fetch latest power data from FactorioLab and update entityPower.json"
  task sync: :environment do
    require "json"
    require "open3"

    factoriolab_url = "https://raw.githubusercontent.com/factoriolab/factoriolab/main/src/data/dsp/data.json"
    output_path = Rails.root.join("app/javascript/data/entityPower.json")

    puts "Fetching power data from FactorioLab..."

    # Use curl to avoid Ruby SSL issues on macOS
    stdout, stderr, status = Open3.capture3("curl", "-s", "-f", factoriolab_url)
    raise "Failed to fetch data: #{stderr}" unless status.success?

    source_data = JSON.parse(stdout)

    # Map FactorioLab string IDs to our numeric entity IDs
    entities = Engine::Entities.instance
    power_data = {}

    source_data["items"].each do |item|
      next unless item["machine"] # Skip items without machine/power data

      # Find matching entity by name
      entity_id = entities.get_uuid(item["name"])
      next unless entity_id

      machine = item["machine"]
      power_data[entity_id] = {
        idle: ((machine["drain"] || 0) * 1000).to_i, # Convert kW to W
        work: ((machine["usage"] || 0) * 1000).to_i  # Convert kW to W
      }
    end

    File.write(output_path, JSON.pretty_generate(power_data))
    puts "Updated #{output_path} with #{power_data.size} entities"
  end
end
