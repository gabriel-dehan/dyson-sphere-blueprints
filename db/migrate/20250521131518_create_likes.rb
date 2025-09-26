class CreateLikes < ActiveRecord::Migration[6.1]
  def change
    create_table :likes do |t|
      t.integer :likes_count, default: 0
      t.references :likable, polymorphic: true, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :likes, [:likable_type, :likable_id, :user_id], unique: true
  end
end
