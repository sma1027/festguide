class InstagramPost < ActiveRecord::Base
  belongs_to :instagram_account

  include Timeago::InstanceMethods
end
