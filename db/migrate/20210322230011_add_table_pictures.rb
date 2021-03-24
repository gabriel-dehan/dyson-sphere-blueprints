class AddTablePictures < ActiveRecord::Migration[6.1]
  def change
    create_table :pictures do |t|
      t.references :blueprint, foreign_key: true
      t.text       :picture_data

      t.timestamps
    end
  end
end
