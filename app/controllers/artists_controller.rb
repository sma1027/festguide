class ArtistsController < ApplicationController
  def index
    @artists = Artist.all
  end

  def show
    @artist = Artist.find(params[:id])
  end

  def edit
    if user_signed_in? && current_user.admin?
      @artist = Artist.find(params[:id])
    else
      redirect_to artist_path
    end
  end
end
