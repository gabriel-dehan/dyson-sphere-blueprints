class AddUpdatedAtIndexToBlueprints < ActiveRecord::Migration[6.1]
  def change
    add_index :blueprints, :updated_at
  end
end
