class AddParentIdToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :parent_id, :integer
    add_index :comments, :parent_id
    add_foreign_key :comments, :comments, column: :parent_id, on_delete: :cascade
  end
end
