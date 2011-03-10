class AddExternalPlaces < ActiveRecord::Migration
  def self.up
    create_table :gowalla_places do |t|
      t.string    :name, :null => false
      t.string    :street_address
      t.string    :region
      t.string    :locality
      t.string    :iso3166
      t.integer   :radius_meters
      t.decimal   :lat, :precision => 11, :scale => 9, :null => false
      t.decimal   :lng, :precision => 12, :scale => 9, :null => false
      t.string    :phone_number
      t.string    :categories
      t.string    :gowalla_id, :null => false
      t.string    :foursquare_id
      t.integer   :place_id, :null => false
      t.timestamps
    end
    add_index :gowalla_places, :gowalla_id, :unique => true
    add_index :gowalla_places, :place_id
    add_index :gowalla_places, [:lat, :lng]
    
    create_table :foursquare_places do |t|
      t.string    :name
      t.string    :categories
      t.string    :address
      t.string    :cross_street
      t.string    :city
      t.string    :state
      t.string    :postal_code
      t.string    :country
      t.decimal   :lat, :precision => 11, :scale => 9, :null => false
      t.decimal   :lng, :precision => 12, :scale => 9, :null => false
      t.string    :phone
      t.string    :twitter
      t.string    :foursquare_id, :null => false
      t.integer   :place_id, :null => false
      t.timestamps
    end
    add_index :foursquare_places, :foursquare_id, :unique => true
    add_index :foursquare_places, :place_id
    add_index :foursquare_places, [:lat, :lng]
    
    create_table :yelp_places do |t|
      t.string    :name
      t.string    :phone
      t.string    :address
      t.string    :city
      t.string    :state_code
      t.string    :country_code
      t.string    :postal_code
      t.string    :cross_streets
      t.string    :display_address
      t.string    :neighborhoods
      t.string    :categories
      t.integer   :geo_accuracy
      t.decimal   :lat, :precision => 11, :scale => 9, :null => false
      t.decimal   :lng, :precision => 12, :scale => 9, :null => false
      t.string    :yelp_id, :null => false
      t.integer   :place_id, :null => false
      t.timestamps
    end
    add_index :yelp_places, :yelp_id, :unique => true
    add_index :yelp_places, :place_id
    add_index :yelp_places, [:lat, :lng]
    
    create_table :facebook_places do |t|
      t.string    :name
      t.string    :category
      t.string    :street
      t.string    :city
      t.string    :state
      t.string    :country
      t.string    :zip
      t.decimal   :lat, :precision => 11, :scale => 9, :null => false
      t.decimal   :lng, :precision => 12, :scale => 9, :null => false
      t.string    :facebook_id, :null => false
      t.integer   :place_id, :null => false
      t.timestamps
    end
    add_index :facebook_places, :facebook_id, :unique => true
    add_index :facebook_places, :place_id
    add_index :facebook_places, [:lat, :lng]
  end

  def self.down
    drop_table :yelp_places
    drop_table :facebook_places
    drop_table :foursquare_places
    drop_table :gowalla_places
  end
end
