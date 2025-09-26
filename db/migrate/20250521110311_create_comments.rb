class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments do |t|
      t.text :content
      t.references :blueprint, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :parent_id
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :comments, :parent_id
    add_foreign_key :comments, :comments, column: :parent_id, on_delete: :cascade
  end
end
