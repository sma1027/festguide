class AddTwitterIdToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :twitter_id, :string
  end
end
