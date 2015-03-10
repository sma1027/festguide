# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Artist.create_artists

Artist.all.each do |artist|
  artist.create_instagram_account(:username => "")
  artist.create_twitter_account(:username => "")
  artist.create_youtube_account(:username => "")
end

User.create(:email => 'sofia.ma@gmail.com', :password => 'sofia123', :admin => true)