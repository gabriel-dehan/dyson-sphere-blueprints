class CreateMods < ActiveRecord::Migration[6.1]
  def change
    create_table :mods do |t|
      t.string :name, null: false
      t.string :author, null: false
      t.string :uuid4, null: false
      t.json :versions

      t.timestamps
    end
  end
end
