class RenameBlueprintModIdToGameVersionId < ActiveRecord::Migration[6.1]
  def change
    rename_column :blueprints, :mod_id, :game_version_id
  end
end
