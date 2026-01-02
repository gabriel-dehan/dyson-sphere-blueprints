class AddPreferredLocaleToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :preferred_locale, :string
  end
end
