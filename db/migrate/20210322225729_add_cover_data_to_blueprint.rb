class AddCoverDataToBlueprint < ActiveRecord::Migration[6.1]
  def change
    add_column :blueprints, :cover_data, :text
  end
end
