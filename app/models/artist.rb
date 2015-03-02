# require 'nokogiri'
require 'open-uri'

class Artist < ActiveRecord::Base

  def self.create_artists
    html = Nokogiri::HTML(open('http://www.edmsauce.com/artists/'))
    html.css('h2').each do |artist| 
      self.create(:name => artist.text)
    end
  end

  def get_instagram_id
    url = "https://api.instagram.com/v1/users/search?q=#{self.instagram_username}&client_id=#{ENV['INSTAGRAM_KEY']}"
    results = JSON.load(open(url))

    if results['data'].first['username'] == self.instagram_username
      self.update(:instagram_id => results['data'].first['id'])
    end
  end

  def get_instagram_images
    images = []

    if !self.instagram_id.blank?
      url = "https://api.instagram.com/v1/users/#{self.instagram_id}/media/recent/?client_id=#{ENV['INSTAGRAM_KEY']}"
      results = JSON.load(open(url))
      results['data'].each do |r|
        image = {}
        image['thumbnail'] = r['images']['thumbnail']['url']
        image['caption_text'] = r['caption']['text']
        image['caption_time'] = Time.at((r['caption']['created_time']).to_i)
        image['std_resolution'] = r['images']['standard_resolution']['url']
        images << image
      end
    end

    images
  end

  def get_youtube_playlist_upload_id
    url = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername=#{self.youtube_username}&key=#{ENV['YOUTUBE_KEY']}"

    results = JSON.load(open(url))

    self.update(:youtube_playlist_upload_id => results["items"][0]["contentDetails"]["relatedPlaylists"]["uploads"])
  end

  def get_youtube_videos
    videos = []
    
    if !self.youtube_playlist_upload_id.blank?
      url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=20&playlistId=#{self.youtube_playlist_upload_id}&key=#{ENV['YOUTUBE_KEY']}"
      results = JSON.load(open(url))

      results['items'].each do |r|
        video = {}

        video['id'] = r['snippet']['resourceId']['videoId']
        video['thumbnail'] = r['snippet']['thumbnails']['default']['url']
        video['title'] = r['snippet']['title']
        video['published_time'] = r['snippet']['publishedAt']
        videos << video
      end
    end
    videos
  end

end
