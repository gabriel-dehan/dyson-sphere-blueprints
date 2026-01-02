class Engine::Recipes
  include Singleton

  GAME_RECIPES_PATH = Rails.root.join("app/javascript/data/gameRecipes.json")

  def initialize
    @recipes_map = JSON.parse(File.read(GAME_RECIPES_PATH))
  end

  # Locale-aware name lookup
  def get_name(recipe_uuid, locale: I18n.locale)
    # Try i18n translation first
    i18n_key = "game.recipes.#{recipe_uuid}"
    translated = I18n.t(i18n_key, locale: locale, default: nil)
    return translated if translated.present?

    # Fallback to JSON data (English)
    get_english_name(recipe_uuid)
  end

  # Always returns English name (for data storage)
  def get_english_name(recipe_uuid)
    recipe = @recipes_map.find { |id, _recipe_name| id.to_s == recipe_uuid.to_s }
    recipe ? recipe[1] : "Not set"
  end
end
