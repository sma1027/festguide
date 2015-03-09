require 'open-uri'

class Artist < ActiveRecord::Base
  validates :name, :uniqueness => true

  has_one :instagram
  accepts_nested_attributes_for :instagram

  has_one :twitter_account
  accepts_nested_attributes_for :twitter_account

  has_many :youtube_videos

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
    url = "https://api.instagram.com/v1/users/#{self.instagram.userid}/media/recent/?client_id=#{ENV['INSTAGRAM_KEY']}"
    results = JSON.load(open(url))

    if self.instagram.instagram_posts.count != 20
      results['data'].reverse.each do |r|
        self.add_instagram_post(r)
      end
    else
      count = 0
      
      results['data'].each do |r|
        if !self.instagram.instagram_posts.where(:source_url => r['link'])
          count += 1
        else
          break
        end
      end

      while count > 0
        results['data'][count-1].each do |r|
          self.add_instagram_post(r)
        end
        self.instagram.instagram_posts.first.destroy
        count -= 1
      end
    end
  end

  def add_instagram_post(r)
    self.instagram.instagram_posts.create(
      :caption_time => Time.at((r['created_time']).to_i),
      :thumbnail_url => r['images']['thumbnail']['url'],
      :source_url => r['link'],
      :likes => r['likes']['count']
      )
    if !r['caption'].nil?
      self.instagram.instagram_posts.last.update(:caption_text => r['caption']['text'])
    end
    if r['type'] == 'image'
      self.instagram.instagram_posts.last.update(:std_resolution_url => r['images']['standard_resolution']['url'])
    elsif r['type'] == 'video'
      self.instagram.instagram_posts.last.update(:std_resolution_url => r['videos']['standard_resolution']['url'])
    end
  end

  def get_twitter_tweets
    twitter = TwitterApi.new.client

    if self.twitter_account.twitter_tweets.count != 10
       twitter.user_timeline("#{self.twitter_account.username}", :count => 10).reverse.each do |tweet|
        self.add_twitter_tweet(twitter, tweet)
      end
    else
      twitter.user_timeline("#{self.twitter_account.username}", :count => 10).each do |tweet|
          
        if self.twitter_account.twitter_tweets.where(:tweet_id => tweet.id)
          break
        else
          self.add_twitter_tweet(tweet)
          self.twitter_account.twitter_tweets.first.destroy
        end
      end
    end
  end

  def add_twitter_tweet(twitter, tweet)
    self.twitter_account.twitter_tweets.create(:tweet_id => tweet.id)

    twitter.status(tweet.id)
    self.twitter_account.twitter_tweets.last.update(
      :text => twitter.status(tweet.id).text,
      :time => twitter.status(tweet.id).created_at,
      :source_url => twitter.status(tweet.id).url.to_s
    )
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

end
