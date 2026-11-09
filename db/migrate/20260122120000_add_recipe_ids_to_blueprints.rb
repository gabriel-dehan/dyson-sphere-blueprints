class AddRecipeIdsToBlueprints < ActiveRecord::Migration[6.1]
  def change
    add_column :blueprints, :recipe_ids, :integer, array: true, if_not_exists: true
  end
end
