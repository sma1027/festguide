class AddYoutubeAccountIdToYoutubeVideos < ActiveRecord::Migration
  def change
    add_column :youtube_videos, :youtube_account_id, :integer
  end
end
