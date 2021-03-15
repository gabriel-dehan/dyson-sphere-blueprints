class AddSlugToBlueprints < ActiveRecord::Migration[6.1]
  def change
    add_column :blueprints, :slug, :string
    add_index :blueprints, :slug, unique: true
  end
end
