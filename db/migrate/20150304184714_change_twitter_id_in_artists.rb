class ChangeTwitterIdInArtists < ActiveRecord::Migration
  def change
    rename_column :artists, :twitter_id, :twitter_username
  end
end
