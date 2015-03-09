class DropTwitterAndYoutubeUsernameInArtists < ActiveRecord::Migration
  def change
    remove_column :artists, :twitter_username
    remove_column :artists, :youtube_username
    remove_column :youtube_videos, :artist_id
  end
end
