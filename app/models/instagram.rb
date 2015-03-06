class Instagram < ActiveRecord::Base
  belongs_to :artist
  validates :username, :uniqueness => true, :allow_blank => true

  include Slugifiable::InstanceMethods
  before_save :downcase_username

  has_many :instagram_posts
end
