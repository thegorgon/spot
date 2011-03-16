class TrackHistory < ActiveRecord::Migration
  def self.up
    create_table :activity_items do |t|
      t.integer   :actor_id
      t.integer   :activity_id
      t.string    :activity_type
      t.integer   :item_id
      t.string    :item_type
      t.integer   :source_id
      t.string    :source_type
      t.string    :action, :null => false
      t.boolean   :public, :null => false, :default => false
      t.decimal   :lat, :precision => 11, :scale => 9, :null => false
      t.decimal   :lng, :precision => 12, :scale => 9, :null => false
      t.datetime  :created_at      
    end
    add_index :activity_items, [:actor_id, :activity_type]
    
    add_column :users, :full_name, :string
    add_column :users, :email, :string
    
    add_column :wishlist_items, :source_type, :string
    add_column :wishlist_items, :source_id, :integer
    add_column :wishlist_items, :deleted_at, :datetime
  end

  def self.down
    drop_table :activity_items
    remove_column :users, :full_name, :email
    remove_column :wishlist_items, :source_id, :source_type, :deleted_at
  end
end
