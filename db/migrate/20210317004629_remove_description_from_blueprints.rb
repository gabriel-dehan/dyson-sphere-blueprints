class RemoveDescriptionFromBlueprints < ActiveRecord::Migration[6.1]
  def up
    remove_column :blueprints, :description
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
