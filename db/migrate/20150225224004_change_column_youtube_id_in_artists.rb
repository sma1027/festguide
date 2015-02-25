class ChangeColumnYoutubeIdInArtists < ActiveRecord::Migration
  def change
    rename_column :artists, :youtube_id, :youtube_playlist_upload_id
  end
end
