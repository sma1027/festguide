class TwitterAccount < ActiveRecord::Base
  belongs_to :artist
  has_many :twitter_tweets, :dependent => :destroy

  validates :username, :uniqueness => true, :allow_blank => true

  include Slugifiable::InstanceMethods
  before_save :downcase_username

  def get_twitter_tweets
    twitter_api_client = TwitterApi.new.client

    if self.twitter_tweets.count != 10
       twitter_api_client.user_timeline("#{self.username}", :count => 10).reverse.each do |tweet|
        self.add_twitter_tweet(twitter_api_client, tweet)
      end
    else
      twitter_api_client.user_timeline("#{self.username}", :count => 10).reverse.each do |tweet|
        if !self.twitter_tweets.exists?(:tweet_id => tweet.id)
          self.add_twitter_tweet(twitter_api_client,tweet)
          self.twitter_tweets.first.destroy
          binding.pry
        end        
      end
    end
  end

  def add_twitter_tweet(twitter_api_client, tweet)
    self.twitter_tweets.create(:tweet_id => tweet.id)

    twitter_api_client.status(tweet.id)
    self.twitter_tweets.last.update(
      :text => twitter_api_client.status(tweet.id).text,
      :time => twitter_api_client.status(tweet.id).created_at,
      :source_url => twitter_api_client.status(tweet.id).url.to_s
    )
  end
end