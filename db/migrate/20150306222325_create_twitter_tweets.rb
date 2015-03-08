class CreateTwitterTweets < ActiveRecord::Migration
  def change
    create_table :twitter_tweets do |t|
      t.text :text
      t.datetime :time
      t.string :source_url

      t.timestamps
    end
  end
end
