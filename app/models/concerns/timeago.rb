module Timeago
  module InstanceMethods
    def time_ago(time)
    difference = Time.now - time
    
    case 
    when difference < 60
      time_from_now = difference
      time_unit = "second"
    when difference < 3600
      time_from_now = difference/60
      time_unit = "minute"
    when difference < 86400
      time_from_now = difference/(60*60)
      time_unit = "hour"
    when difference < 604800
      time_from_now = difference/(60*60*24)
      time_unit = "day"
    else
      time_from_now = difference/(60*60*24*7)
      time_unit = "week"
    end

    time_from_now = time_from_now.floor

    if time_from_now > 1
      time_unit += 's'
    end

    "#{time_from_now} #{time_unit} ago"
    end
  end
end