class CreateYoutubeAccounts < ActiveRecord::Migration
  def change
    create_table :youtube_accounts do |t|
      t.string :username
      t.integer :playlist_upload_id, :limit => 8
      t.string :playlist_upload_url
      t.integer :artist_id

      t.timestamps
    end
  end
end
