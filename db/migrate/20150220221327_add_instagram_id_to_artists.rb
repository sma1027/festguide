class AddInstagramIdToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :instagram_id, :string
  end
end
