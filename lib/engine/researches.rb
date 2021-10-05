class Engine::Researches
  include Singleton

  GAME_RESEARCHES_PATH = Rails.root.join("app/javascript/data/gameResearches.json")
  MASS_CONSTRUCTION_LIMITS = {
    "mass-1" => 60,
    "mass-2" => 150,
    "mass-3" => 600,
    "mass-4" => 3000,
    "mass-5" => Float::INFINITY,
  }.freeze

  def initialize
    @researches_map = JSON.parse(File.read(GAME_RESEARCHES_PATH))
  end

  def formatted_mass_construction_with_limits
    @@formatted_mass_construction_with_limits ||= MASS_CONSTRUCTION_LIMITS.map { |key, limit| [key, "#{@researches_map[key]} (#{limit})"] }.to_h # rubocop:disable Style/ClassVars
  end

  def get_name(research_uuid)
    research = @researches_map.find { |id, _research_name| id.to_s == research_uuid.to_s }
    research ? research[1] : "Unknown"
  end
end
