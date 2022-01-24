class CreateBlueprintMechaColors < ActiveRecord::Migration[6.1]
  def change
    create_table :blueprint_mecha_colors do |t|
      t.references :blueprint
      t.references :color
      t.timestamps
    end
  end
end
