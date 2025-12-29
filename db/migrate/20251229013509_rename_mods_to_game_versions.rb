class RenameModsToGameVersions < ActiveRecord::Migration[6.1]
  def change
    rename_table :mods, :game_versions
  end
end
