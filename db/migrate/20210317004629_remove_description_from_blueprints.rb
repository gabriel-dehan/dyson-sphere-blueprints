class RemoveDescriptionFromBlueprints < ActiveRecord::Migration[6.1]
  def change
    remove_column :blueprints, :description
  end
end
