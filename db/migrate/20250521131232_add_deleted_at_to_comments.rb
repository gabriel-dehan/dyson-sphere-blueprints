class AddDeletedAtToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :deleted_at, :datetime
  end
end
