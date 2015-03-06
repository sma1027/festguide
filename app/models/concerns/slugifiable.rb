module Slugifiable
  module InstanceMethods
    def to_slug
      self.name.downcase.gsub(" ","-")
    end

    def downcase_username
      self.username.downcase!
    end
  end
end