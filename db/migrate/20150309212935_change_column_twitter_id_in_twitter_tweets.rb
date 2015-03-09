class ChangeColumnTwitterIdInTwitterTweets < ActiveRecord::Migration
  def change
    change_column :twitter_tweets, :tweet_id, :integer, :limit => 8
  end
end
