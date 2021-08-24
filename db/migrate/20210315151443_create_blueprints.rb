class CreateBlueprints < ActiveRecord::Migration[6.1]
  def change
    create_table :blueprints do |t|
      t.string :title,          null: false
      t.text :description
      t.text :encoded_blueprint, null: false
      t.references :collection, foreign_key: true
      t.timestamps
    end
  end
end
