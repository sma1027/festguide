class AddYoutubeUsernameToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :youtube_username, :string
  end
end
