class CreateCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :collections do |t|
      t.string :name, null: false
      t.integer :type, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :collections, :type
  end
end
