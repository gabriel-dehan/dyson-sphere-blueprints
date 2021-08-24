class AddOmniauthToUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :provider
      t.string :uid
      t.string :discord_avatar_url
      t.string :token
      t.datetime :token_expiry
    end
  end
end
