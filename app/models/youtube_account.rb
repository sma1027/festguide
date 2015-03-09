class YoutubeAccount < ActiveRecord::Base
  belongs_to :artist
  has_many :youtube_videos, :dependent => :destroy

  validates :username, :uniqueness => true, :allow_blank => true

  def get_playlist_upload_id
    url = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername=#{self.username}&key=#{ENV['YOUTUBE_KEY']}"
    results = JSON.load(open(url))
    self.update(:playlist_upload_id => results["items"][0]["contentDetails"]["relatedPlaylists"]["uploads"])
  end

  def get_playlist_upload_url
    url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=#{self.playlist_upload_id}&key=#{ENV['YOUTUBE_KEY']}"
    self.update(:playlist_upload_url => url)
  end
end
