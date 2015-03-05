class ArtistsController < ApplicationController

  def index
    @artists = Artist.all.where(:approved => true).sort_by{|a| a.name.downcase}
    @artists_not_approved = Artist.all.where(:approved => false).sort_by{|a| a.name.downcase}
  end

  def new
    @artist = Artist.new
    @artist.build_instagram
  end

  def create
    @artist = Artist.new(artist_params)
    if @artist.approved == true && @artist.save 
      redirect_to @artist
    elsif @artist.approved == false && @artist.save
      redirect_to root_path
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
    if !@artist.youtube_username.blank?
      @artist.get_youtube_playlist_upload_id
      @artist.get_youtube_videos
    end
    redirect_to @artist
  end

  private
    def artist_params
      params.require(:artist).permit(:name, :approved, :instagram_attributes => [:username])
    end
end
