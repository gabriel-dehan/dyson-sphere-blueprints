class AddDecodedBlueprintToBlueprints < ActiveRecord::Migration[6.1]
  def change
    add_column :blueprints, :decoded_blueprint_data, :json
  end
end
