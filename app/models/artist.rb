require 'open-uri'

class Artist < ActiveRecord::Base
  has_one :instagram
  accepts_nested_attributes_for :instagram

  has_many :youtube_videos

  validates :name, :uniqueness => true

  include Slugifiable::InstanceMethods
  include Timeago::InstanceMethods

  def self.create_artists
    html = Nokogiri::HTML(open('http://www.djmag.com/top-100-djs'))
    html.css('.views-field-title a').each do |artist| 
      self.create(:name => artist.text, :approved => true)
    end
  end

  def get_instagram_id
    url = "https://api.instagram.com/v1/users/search?q=#{self.instagram.username}&client_id=#{ENV['INSTAGRAM_KEY']}"
    results = JSON.load(open(url))

    results['data'].each do |r|
      if r['username'] == self.instagram.username
        self.instagram.update(:userid => r['id'])
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
        post['caption_time'] = time_ago(Time.at((r['caption']['created_time']).to_i))
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
    twitter = TwitterApi.new
    tweet_ids = []

    twitter.user_timeline("#{self.twitter_username}").each do |tweet|
      tweet_ids << tweet.id
    end

    tweets = []
    tweet_ids.each do |tweet_id|
      tweets << twitter.status(tweet_id)
    end

    tweets
  end

end
