class ChangeColumnTwitterIdInTwitterTweetsToBigInt < ActiveRecord::Migration
  def change
    change_column :twitter_tweets, :tweet_id, :bigint
  end
end
