class Engine::Entities
  include Singleton

  GAME_ENTITIES_PATH = Rails.root.join("app/javascript/data/gameEntities.json")

  BELTS = [2001, 2002, 2003].freeze
  SORTERS = [2011, 2012, 2013, 2014].freeze
  STORAGES = [2101, 2102, 2106].freeze
  BUILDERS = [2303, 2304, 2305, 2302, 2308, 2309, 2310, 2901].freeze
  ASSEMBLERS = [2303, 2304, 2305].freeze
  SMELTER = [2302].freeze
  POWER_GENERATORS = [2203, 2204, 2211, 2210, 2208].freeze

  def initialize
    @entities_map = JSON.parse(File.read(GAME_ENTITIES_PATH))
  end

  def get_uuid(name)
    entity = @entities_map.find { |_id, entity_name| entity_name.casecmp(name).zero? }
    entity ? entity[0] : nil
  end

  # Locale-aware name lookup
  def get_name(entity_uuid, locale: I18n.locale)
    # Try i18n translation first
    i18n_key = "game.entities.#{entity_uuid}"
    translated = I18n.t(i18n_key, locale: locale, default: nil)
    return translated if translated.present?

    # Fallback to JSON data (English)
    get_english_name(entity_uuid)
  end

  # Always returns English name (for data storage)
  def get_english_name(entity_uuid)
    entity = @entities_map.find { |id, _entity_name| id.to_s == entity_uuid.to_s }
    entity ? entity[1] : "Unknown"
  end

  def is_builder?(entity_uuid)
    BUILDERS.include?(entity_uuid)
  end

  def is_smelter?(entity_uuid)
    entity_uuid == SMELTER
  end

  def is_assembler?(entity_uuid)
    ASSEMBLERS.include?(entity_uuid)
  end

  def is_sorter?(entity_uuid)
    SORTERS.include?(entity_uuid)
  end

  def is_belt?(entity_uuid)
    BELTS.include?(entity_uuid)
  end

  def is_storage?(entity_uuid)
    STORAGES.include?(entity_uuid)
  end

  def is_power_generator?(entity_uuid)
    POWER_GENERATORS.include(entity_uuid)
  end

  def is_power_consumer?(_entity_uuid)
    # TODO
    false
  end
end
