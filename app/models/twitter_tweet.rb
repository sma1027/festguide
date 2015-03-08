class TwitterTweet < ActiveRecord::Base
  belongs_to :twitter_account
  
  include Timeago::InstanceMethods
end
