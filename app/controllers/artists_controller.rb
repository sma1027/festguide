class ArtistsController < ApplicationController

  def index
    @artists = Artist.all.where(:approved => true).sort_by{|a| a.name.downcase}
    @artists_not_approved = Artist.all.where(:approved => false).sort_by{|a| a.name.downcase}
  end

  def new
    @artist = Artist.new
    @artist.build_instagram
    @artist.build_twitter_account
  end

  def create
    @artist = Artist.new(artist_params)
    if @artist.approved == true && @artist.save 
      redirect_to @artist
    elsif @artist.approved == false && @artist.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def show
    @artist = Artist.find(params[:id])
  end

  def edit
    if user_signed_in? && current_user.admin?
      @artist = Artist.find(params[:id])
      @artist.build_instagram if @artist.instagram.nil? 
      @artist.build_twitter_account if @artist.twitter_account.nil? 
    else
      redirect_to artist_path
    end
  end

  def update
    @artist = Artist.find(params[:id])
    if @artist.update(artist_params)
      @artist.get_instagram_id   
      redirect_to @artist
    else
      render 'edit'
    end
  end

  private
    def artist_params
      params.require(:artist).permit(:name, :approved, :instagram_attributes => [:id, :username], :twitter_account_attributes => [:id, :username])
    end
end
