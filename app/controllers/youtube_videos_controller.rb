class YoutubeVideosController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id])

    @artist.youtube_account.get_youtube_videos
    @youtube_videos = @artist.youtube_account.youtube_videos.reverse_order
  end
end
