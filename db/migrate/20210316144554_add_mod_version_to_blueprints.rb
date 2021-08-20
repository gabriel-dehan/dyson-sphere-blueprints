class AddModVersionToBlueprints < ActiveRecord::Migration[6.1]
  def change
    add_reference :blueprints, :mod, foreign_key: true, index: true
    add_column :blueprints, :mod_version, :string, null: false # rubocop:disable Rails/NotNullColumn
  end
end
