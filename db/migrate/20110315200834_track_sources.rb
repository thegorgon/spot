class TrackSources < ActiveRecord::Migration
  def self.up
    add_column :wishlist_items, :source_type, :string
    add_column :wishlist_items, :source_id, :integer
  end

  def self.down
    remove_column :wishlist_items, :source_type, :source_id
  end
end
