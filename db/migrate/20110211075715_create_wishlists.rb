class CreateWishlists < ActiveRecord::Migration
  def self.up    
    create_table :wishlist_items do |t|
      t.integer   :user_id, :null => false
      t.integer   :item_id, :null => false
      t.string    :item_type, :null => false
      t.decimal   :lat, :precision => 11, :scale => 9
      t.decimal   :lng, :precision => 12, :scale => 9
      t.timestamps
    end
    add_index :wishlist_items, [:user_id, :item_type, :item_id], :unique => true
  end

  def self.down
    drop_table :wishlist_items
  end
end
