require 'open-uri'

class Artist < ActiveRecord::Base
  validates :name, :uniqueness => true

  has_one :instagram_account, :dependent => :destroy
  accepts_nested_attributes_for :instagram_account
  has_many :instagram_posts, :through => :instagram_account

  has_one :twitter_account, :dependent => :destroy
  accepts_nested_attributes_for :twitter_account
  has_many :twitter_tweets, :through => :twitter_account

  has_one :youtube_account, :dependent => :destroy
  accepts_nested_attributes_for :youtube_account
  has_many :youtube_videos, :through => :youtube_account

  def self.create_artists
    html = Nokogiri::HTML(open('http://www.djmag.com/top-100-djs'))
    html.css('.views-field-title a').each do |artist| 
      self.create(:name => artist.text, :approved => true)
    end
  end
end
