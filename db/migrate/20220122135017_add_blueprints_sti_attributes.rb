class AddBlueprintsStiAttributes < ActiveRecord::Migration[6.1]
  def change
    change_column_null :blueprints, :encoded_blueprint, true

    change_table :blueprints, bulk: true do |t|
      t.string :type
    end

    reversible do |change|
      change.up do
        Blueprint.where(type: nil).update(type: "Factory")
        change_column_null :blueprints, :type, false
      end
    end
  end
end
