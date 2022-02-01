class CreateBlueprintUsageMetrics < ActiveRecord::Migration[6.1]
  def change
    create_table :blueprint_usage_metrics do |t|
      t.references :blueprint
      t.references :user
      t.integer :count, default: 0, null: false
      t.datetime :last_used_at, default: DateTime.now

      t.timestamps
    end

    add_column :blueprints, :usage_count, :integer, default: 0
  end
end
