class CreateInstagrams < ActiveRecord::Migration
  def change
    create_table :instagrams do |t|
      t.string :username
      t.integer :userid
      t.integer :artist_id

      t.timestamps
    end
  end
end
