class TwitterApi
  # attr_accessor :client

  # def initialize
  @@client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end
  # end

  def self.user_timeline(username)
    @@client.user_timeline(username, :count => 5)
  end

  def self.status(tweeet_id)
    tweet = {}
    tweet['text'] = @@client.status(tweeet_id).text
    tweet['created_at'] = @@client.status(tweeet_id).created_at
    tweet['url'] = @@client.status(tweeet_id).url.to_s
    tweet
  end

end