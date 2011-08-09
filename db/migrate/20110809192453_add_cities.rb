class AddCities < ActiveRecord::Migration
  def self.up
    create_table "cities" do |t|
      t.string   "name",                                                                  :null => false
      t.string   "fqn",                                                                   :null => false
      t.string   "slug",                                                                  :null => false
      t.decimal  "lat",                     :precision => 11, :scale => 9,                :null => false
      t.decimal  "lng",                     :precision => 12, :scale => 9,                :null => false
      t.integer  "radius"
      t.integer  "population",                                             :default => 0, :null => false
      t.string   "region",                                                                :null => false
      t.string   "region_code",                                                           :null => false
      t.string   "country_code",                                                          :null => false
      t.integer  "subscriptions_available",                                :default => 0, :null => false
      t.integer  "subscription_count",                                     :default => 0, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "cities", ["slug"], :name => "index_cities_on_slug", :unique => true
  end

  def self.down
    drop_table "cities"
  end
end
