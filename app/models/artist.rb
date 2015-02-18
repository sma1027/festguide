# require 'nokogiri'
require 'open-uri'

class Artist < ActiveRecord::Base
  
  def self.create_artists
    html = Nokogiri::HTML(open('http://www.edmsauce.com/artists/'))
    html.css('h2').each do |artist| 
      self.create(:name => artist.text)
    end
  end

end
