class AddYoutubeIdToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :youtube_id, :string
  end
end
