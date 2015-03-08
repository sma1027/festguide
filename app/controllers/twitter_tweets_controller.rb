class TwitterTweetsController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id])
    @artist.get_twitter_tweets
    @twitter_tweets = @artist.twitter_account.twitter_tweets.reverse
  end
end
