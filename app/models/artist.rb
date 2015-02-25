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
    url = "https://api.instagram.com/v1/users/search?q=#{self.instagram_username}&client_id=#{ENV['INSTAGRAM_ID']}"
    results = JSON.load(open(url))

    if results['data'].first['username'] == self.instagram_username
      self.update(:instagram_id => results['data'].first['id'])
    end
  end

  def display_instagram_images
    images = []

    if !self.instagram_id.blank?
      url = "https://api.instagram.com/v1/users/#{self.instagram_id}/media/recent/?client_id=#{ENV['INSTAGRAM_ID']}"
      results = JSON.load(open(url))
      # binding.pry
      results['data'].each do |r|
        image = {}
        image['thumbnail'] = r['images']['thumbnail']['url']
        image['caption_text'] = r['caption']['text']
        image['caption_time'] = Time.at((r['caption']['created_time']).to_i)
        image['std_resolution'] = r['images']['standard_resolution']['url']
        images << image
      end

    end
    # binding.pry
    images
  end

  def get_youtube_id
  end  

end
