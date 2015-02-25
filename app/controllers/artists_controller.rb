class ArtistsController < ApplicationController
  def index
    @artists = Artist.all.sort_by{|a| a.name.downcase}
  end

  def new
    @artist = Artist.new
  end

  def create
    @artist = Artist.new(artist_params)
    if @artist.save
      redirect_to @artist
    else
      render :new
    end
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

  def update
    @artist = Artist.find(params[:id])
    @artist.update(artist_params)
    if !@artist.instagram_username.blank?
      @artist.get_instagram_id
    end
    redirect_to @artist
  end

  private
    def artist_params
      params.require(:artist).permit(:name, :youtube_id, :instagram_username, :twitter_id)
    end
end
