class AddTwiiterAccountIdToTwitterTweets < ActiveRecord::Migration
  def change
    add_column :twitter_tweets, :twitter_account_id, :integer, :limit => 8
  end
end
