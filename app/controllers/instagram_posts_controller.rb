class InstagramPostsController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id])
    @artist.get_instagram_posts
    @instagram_posts = @artist.instagram.instagram_posts.reverse
  end
end
