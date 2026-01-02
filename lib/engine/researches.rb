class Engine::Researches
  include Singleton

  GAME_RESEARCHES_PATH = Rails.root.join("app/javascript/data/gameResearches.json")
  MASS_CONSTRUCTION_LIMITS = {
    "mass-1" => 150,
    "mass-2" => 300,
    "mass-3" => 900,
    "mass-4" => 3600,
    "mass-5" => Float::INFINITY,
  }.freeze

  def initialize
    @researches_map = JSON.parse(File.read(GAME_RESEARCHES_PATH))
  end

  def formatted_mass_construction_with_limits(locale: I18n.locale)
    MASS_CONSTRUCTION_LIMITS.map { |key, limit| [key, "#{get_name(key, locale: locale)} (#{limit})"] }.to_h
  end

  # Locale-aware name lookup
  def get_name(research_uuid, locale: I18n.locale)
    # Try i18n translation first
    i18n_key = "game.researches.#{research_uuid}"
    translated = I18n.t(i18n_key, locale: locale, default: nil)
    return translated if translated.present?

    # Fallback to JSON data (English)
    get_english_name(research_uuid)
  end

  # Always returns English name (for data storage)
  def get_english_name(research_uuid)
    research = @researches_map.find { |id, _research_name| id.to_s == research_uuid.to_s }
    research ? research[1] : "Unknown"
  end
end
