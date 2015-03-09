class ChangeInstagramIdToInstagramAccountIdInInstagramPost < ActiveRecord::Migration
  def change
    rename_column :instagram_posts, :instagram_id, :instagram_account_id
  end
end
