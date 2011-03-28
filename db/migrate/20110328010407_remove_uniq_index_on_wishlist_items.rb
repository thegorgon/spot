class RemoveUniqIndexOnWishlistItems < ActiveRecord::Migration
  def self.up
    remove_index :wishlist_items, [:user_id, :item_type, :item_id]
    add_index :wishlist_items, [:user_id, :item_type, :item_id]
  end

  def self.down
    remove_index :wishlist_items, [:user_id, :item_type, :item_id]
    add_index :wishlist_items, [:user_id, :item_type, :item_id], :unique => true
  end
end
