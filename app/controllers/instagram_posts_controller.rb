class InstagramPostsController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id])
    @instagram_posts = @artist.get_instagram_posts
  end
end
