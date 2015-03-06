class DropTypeColumnInInstagramPosts < ActiveRecord::Migration
  def change
    remove_column :instagram_posts, :type
  end
end
