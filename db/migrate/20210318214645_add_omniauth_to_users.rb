class AddOmniauthToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :discord_avatar_url, :string
    add_column :users, :token, :string
    add_column :users, :token_expiry, :datetime
  end
end
