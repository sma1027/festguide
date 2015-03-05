class DropColumnInstagramInArtists < ActiveRecord::Migration
  def change
    remove_column :artists, :instagram_username
    remove_column :artists, :instagram_id
  end
end
