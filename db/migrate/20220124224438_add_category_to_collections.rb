class AddCategoryToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :category, :string
  end
end
