class AddInstagramUsernameToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :instagram_username, :string
  end
end
