class YoutubeVideo < ActiveRecord::Base
  belongs_to :youtube_account

  include Timeago::InstanceMethods
end
