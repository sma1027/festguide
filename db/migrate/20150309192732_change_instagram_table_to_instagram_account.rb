class ChangeInstagramTableToInstagramAccount < ActiveRecord::Migration
  def change
    rename_table :instagrams, :instagram_accounts
  end
end
