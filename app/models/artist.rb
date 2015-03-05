require 'open-uri'

class Artist < ActiveRecord::Base
  has_many :youtube_videos

  validates :name, :uniqueness => true

  #need to slugiy the name and check it !!!

  def self.create_artists
    html = Nokogiri::HTML(open('http://www.djmag.com/top-100-djs'))
    html.css('.views-field-title a').each do |artist| 
      self.create(:name => artist.text, :approved => true)
    end
  end

  def get_instagram_id
    url = "https://api.instagram.com/v1/users/search?q=#{self.instagram_username}&client_id=#{ENV['INSTAGRAM_KEY']}"
    results = JSON.load(open(url))

    results['data'].each do |r|
      if r['username'] == self.instagram_username
        self.update(:instagram_id => r['id'])
        break
      end
    end
  end

  def get_instagram_posts
    posts = []

    if !self.instagram_id.blank?
      url = "https://api.instagram.com/v1/users/#{self.instagram_id}/media/recent/?client_id=#{ENV['INSTAGRAM_KEY']}"
      results = JSON.load(open(url))

      results['data'].each do |r|
        post = {}
        post['thumbnail'] = r['images']['thumbnail']['url']
        post['caption_text'] = r['caption']['text']
        post['caption_time'] = self.post_time(Time.at((r['caption']['created_time']).to_i))
        post['type'] = r['type']
        if post['type'] == 'image'
          post['std_resolution'] = r['images']['standard_resolution']['url']
        elsif post['type'] == 'video'
          post['std_resolution'] = r['videos']['standard_resolution']['url']
        end
        post['link'] = r['link']
        post['likes'] = r['likes']['count']

        posts << post
      end
    end

    posts
  end

  def post_time(time)
    difference = Time.now - time

    if difference < 60
      time_from_now = difference
      time_unit = "second"
    elsif difference < 3600
      time_from_now = difference/60
      time_unit = "minute"
    elsif difference < 86400
      time_from_now = difference/(60*60)
      time_unit = "hour"
    elsif difference < 604800
      time_from_now = difference/(60*60*24)
      time_unit = "day"
    else
      time_from_now = difference/(60*60*24*7)
      time_unit = "week"
    end

    time_from_now = time_from_now.floor

    if time_from_now > 1
      time_unit += 's'
    end
    "#{time_from_now} #{time_unit} ago"
  end

  def get_youtube_playlist_upload_id
    url = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername=#{self.youtube_username}&key=#{ENV['YOUTUBE_KEY']}"
    results = JSON.load(open(url))

    self.update(:youtube_playlist_upload_id => results["items"][0]["contentDetails"]["relatedPlaylists"]["uploads"])
  end

  def get_youtube_playlist_upload_url
    url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=#{self.youtube_playlist_upload_id}&key=#{ENV['YOUTUBE_KEY']}"
  end

  def get_youtube_videos
    videos = []

    if !self.youtube_playlist_upload_id.blank?
      url = self.get_youtube_playlist_upload_url

      loop do 
        results = JSON.load(open(url))

        results['items'].each do |r|
          self.youtube_videos.create(
            :artist_id => self.id,
            :video_id => r['snippet']['resourceId']['videoId'],
            :title => r['snippet']['title'],
            :thumbnail => r['snippet']['thumbnails']['default']['url'],
            :published_time => r['snippet']['publishedAt']
          )
        end

        if results['nextPageToken']
          url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&pageToken=#{results['nextPageToken']}&playlistId=#{self.youtube_playlist_upload_id}&key=#{ENV['YOUTUBE_KEY']}"
        end

        break if results['nextPageToken'] == nil
      end
    end
  end

  def get_youtube_videos_total_count
    url = self.get_youtube_playlist_upload_url
    results = JSON.load(open(url))
    
    count = results['pageInfo']['totalResults']
  end

  def get_youtube_videos_latest
    url = self.get_youtube_playlist_upload_url
    results = JSON.load(open(url))

    results['items'].each do |r|
      if self.youtube_videos.where(:video_id => r['snippet']['resourceId']['videoId'])
        break
      else
        self.youtube_videos.create(
          :artist_id => self.id,
          :video_id => r['snippet']['resourceId']['videoId'],
          :title => r['snippet']['title'],
          :thumbnail => r['snippet']['thumbnails']['default']['url'],
          :published_time => r['snippet']['publishedAt']
        )
      end
    end
  end


  def get_twitter_tweets
    tweet_ids = []

    TwitterApi.user_timeline("#{self.twitter_username}").each do |tweet|
      tweet_ids << tweet.id
    end

    tweets = []
    tweet_ids.each do |tweet_id|
      tweets << TwitterApi.status(tweet_id)
    end

    tweets
  end

end
