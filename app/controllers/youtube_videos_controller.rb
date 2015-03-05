class YoutubeVideosController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id])
    @artist.get_youtube_videos
    @youtube_videos = @artist.youtube_videos
  end
end
