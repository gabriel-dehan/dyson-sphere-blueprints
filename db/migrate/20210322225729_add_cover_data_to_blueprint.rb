class AddCoverDataToBlueprint < ActiveRecord::Migration[6.1]
  def change
    add_column :blueprints, :cover_picture_data, :text
  end
end
