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
    url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=10&playlistId=#{self.playlist_upload_id}"
    self.update(:playlist_upload_url => url)
  end

  def get_youtube_videos
    url = "#{self.playlist_upload_url}&key=#{ENV['YOUTUBE_KEY']}"
    results = JSON.load(open(url))

    if self.youtube_videos.count != 10
      results['items'].reverse.each do |r|
        self.add_youtube_video(r)
      end
    else
      count = 0
      
      results['items'].each do |r|
        if !self.youtube_videos.where(:video_id => r['snippet']['resourceId']['videoId'])
          count += 1
        else
          break
        end
      end

      while count > 0
        results['items'][count-1].each do |r|
          self.add_youtube_video(r)
        end
        self.youtube_videos.first.destroy
        count -= 1
      end
    end
  end

  def add_youtube_video(r)
    self.youtube_videos.create(
      :video_id => r['snippet']['resourceId']['videoId'],
      :title => r['snippet']['title'],
      :thumbnail => r['snippet']['thumbnails']['default']['url'],
      :published_time => r['snippet']['publishedAt']
    )
  end
end
