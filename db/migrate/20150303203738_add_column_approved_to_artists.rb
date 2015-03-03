class AddColumnApprovedToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :approved, :boolean, :default => false
  end
end
