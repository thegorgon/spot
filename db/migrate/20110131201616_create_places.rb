class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.string    :full_name, :null => false
      t.string    :full_address
      t.string    :clean_name, :null => false
      t.string    :clean_address
      t.string    :phone_number
      t.string    :source
      t.integer   :status, :limit => 4, :null => false, :default => 0
      t.decimal   :lat, :precision => 11, :scale => 9
      t.decimal   :lng, :precision => 12, :scale => 9
      t.text      :image_thumbnail
      t.string    :image_file_name
      t.datetime  :image_updated_at
      t.integer   :wishlist_count, :null => false, :default => 0
      t.timestamps
    end
    add_index :places, [:lat, :lng]
        
    create_table :google_places do |t|
      t.string    :cid, :null => false
      t.integer   :place_id, :null => false
      t.string    :name
      t.string    :listing_type
      t.string    :street_address
      t.string    :city
      t.string    :region
      t.string    :country
      t.text      :address
      t.string    :phone_number
      t.decimal   :lat, :precision => 11, :scale => 9, :null => false
      t.decimal   :lng, :precision => 12, :scale => 9, :null => false
      t.timestamps
    end
    add_index :google_places, :cid, :unique => true
    add_index :google_places, :place_id
    add_index :google_places, [:lat, :lng]
  end

  def self.down
    drop_table :places
    drop_table :google_places
  end
end
