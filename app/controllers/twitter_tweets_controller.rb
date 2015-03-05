class TwitterTweetsController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id])
    @twitter_tweets = @artist.get_twitter_tweets
  end
end
