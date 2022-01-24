class AddBlueprintFileToBlueprints < ActiveRecord::Migration[6.1]
  def change
    add_column :blueprints, :blueprint_file_data, :text
  end
end
