class InstagramPostsController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id])
    @artist.instagram_account.get_instagram_posts
    @instagram_posts = @artist.instagram_account.instagram_posts.reverse
  end
end
