class ChangeColumnPlaylistUploadIdToString < ActiveRecord::Migration
  def change
    change_column :youtube_accounts, :playlist_upload_id, :string
  end
end
