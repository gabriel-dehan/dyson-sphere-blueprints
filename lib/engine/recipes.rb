class Engine::Recipes
  include Singleton

  GAME_RECIPES_PATH = Rails.root.join("app/javascript/data/gameRecipes.json")

  def initialize
    @recipes_map = JSON.parse(File.read(GAME_RECIPES_PATH))
  end

  def get_name(recipe_uuid)
    recipe = @recipes_map.find { |id, _recipe_name| id.to_s == recipe_uuid.to_s }
    recipe ? recipe[1] : "Not set"
  end
end
