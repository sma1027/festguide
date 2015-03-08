class TwitterAccount < ActiveRecord::Base
  belongs_to :artist

  validates :username, :uniqueness => true, :allow_blank => true

  has_many :twitter_tweets
end