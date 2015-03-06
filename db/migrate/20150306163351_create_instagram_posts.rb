class CreateInstagramPosts < ActiveRecord::Migration
  def change
    create_table :instagram_posts do |t|
      t.datetime :caption_time
      t.text :caption_text
      t.string :type
      t.string :thumbnail_url
      t.string :std_resolution_url
      t.string :source_url
      t.integer :likes
      t.integer :instagram_id

      t.timestamps
    end
  end
end
