class YoutubeVideo < ActiveRecord::Base
  belongs_to :artist

  validates :video_id, :uniqueness => true
end
