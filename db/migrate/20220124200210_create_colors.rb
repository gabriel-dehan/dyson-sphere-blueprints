class CreateColors < ActiveRecord::Migration[6.1]
  def change
    create_table :colors do |t|
      t.string :name, null: false
      t.integer :r, null: false
      t.integer :g, null: false
      t.integer :b, null: false
      t.float :h, null: false
      t.float :s, null: false
      t.float :l, null: false
    end
  end
end
