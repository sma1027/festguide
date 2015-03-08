class AddTweetIdToTwitterTweets < ActiveRecord::Migration
  def change
    add_column :twitter_tweets, :tweet_id, :integer
  end
end
