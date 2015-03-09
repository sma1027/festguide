class Instagram < ActiveRecord::Base
  belongs_to :artist
  validates :username, :uniqueness => true, :allow_blank => true

  include Slugifiable::InstanceMethods
  before_save :downcase_username

  has_many :instagram_posts, :dependent => :destroy

  def get_instagram_id
    url = "https://api.instagram.com/v1/users/search?q=#{self.username}&client_id=#{ENV['INSTAGRAM_KEY']}"
    results = JSON.load(open(url))

    results['data'].each do |r|
      if r['username'] == self.username
        self.update(:userid => r['id'])
        break
      end
    end
  end

  def get_instagram_posts    
    url = "https://api.instagram.com/v1/users/#{self.userid}/media/recent/?client_id=#{ENV['INSTAGRAM_KEY']}"
    results = JSON.load(open(url))

    if self.instagram_posts.count != 10
      results['data'].reverse.each do |r|
        self.add_instagram_post(r)
      end
    else
      count = 0
      
      results['data'].each do |r|
        if !self.instagram_posts.where(:source_url => r['link'])
          count += 1
        else
          break
        end
      end

      while count > 0
        results['data'][count-1].each do |r|
          self.add_instagram_post(r)
        end
        self.instagram_posts.first.destroy
        count -= 1
      end
    end
  end

  def add_instagram_post(r)
    self.instagram_posts.create(
      :caption_time => Time.at((r['created_time']).to_i),
      :thumbnail_url => r['images']['thumbnail']['url'],
      :source_url => r['link'],
      :likes => r['likes']['count']
      )
    if !r['caption'].nil?
      self.instagram_posts.last.update(:caption_text => r['caption']['text'])
    end
    if r['type'] == 'image'
      self.instagram_posts.last.update(:std_resolution_url => r['images']['standard_resolution']['url'])
    elsif r['type'] == 'video'
      self.instagram_posts.last.update(:std_resolution_url => r['videos']['standard_resolution']['url'])
    end
  end

end
