class AddMemoryOptimizationIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :collections, :created_at
    add_index :blueprints, [:collection_id, :cached_votes_total]
    add_index :blueprint_mecha_colors, [:blueprint_id, :color_id],
              name: "index_mecha_colors_on_blueprint_and_color"
  end
end
