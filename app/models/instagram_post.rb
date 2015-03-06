class InstagramPost < ActiveRecord::Base
  belongs_to :instagram

  include Timeago::InstanceMethods
end
