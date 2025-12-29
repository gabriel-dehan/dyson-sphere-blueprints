class RenameBlueprintModVersionToGameVersionString < ActiveRecord::Migration[6.1]
  def change
    rename_column :blueprints, :mod_version, :game_version_string
  end
end
