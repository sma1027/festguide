class CreateYoutubeVideos < ActiveRecord::Migration
  def change
    create_table :youtube_videos do |t|
      t.string :video_id
      t.string :thumbnail
      t.string :title
      t.string :published_time
      t.integer :artist_id

      t.timestamps
    end
  end
end
