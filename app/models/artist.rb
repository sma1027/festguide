# require 'nokogiri'
require 'open-uri'

class Artist < ActiveRecord::Base

  def self.create_artists
    html = Nokogiri::HTML(open('http://www.edmsauce.com/artists/'))
    html.css('h2').each do |artist| 
      self.create(:name => artist.text)
    end
  end

  def find_instagram_id
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

      results['data'].each do |r|
        images << r['images']['thumbnail']['url']
      end
    end
    
    images
  end

end
