class RemoveYoutubePlaylistUploadIdFromArtists < ActiveRecord::Migration
  def change
    remove_column :artists, :youtube_playlist_upload_id
  end
end
