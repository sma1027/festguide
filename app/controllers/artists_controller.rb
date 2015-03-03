class ArtistsController < ApplicationController
  def index
    @artists = Artist.all.where(:approved => true).sort_by{|a| a.name.downcase}
  end

  def new
    @artist = Artist.new
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
    
    if !@artist.youtube_username.blank? && @artist.get_youtube_videos_total_count > 0
      @artist.get_youtube_videos_latest
    end
    
    @youtube_videos = @artist.youtube_videos.order(published_time: :desc)
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
      params.require(:artist).permit(:name, :youtube_username, :instagram_username, :twitter_id, :approved)
    end
end
