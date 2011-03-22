# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110320084739) do

  create_table "activity_items", :force => true do |t|
    t.integer  "actor_id"
    t.integer  "activity_id"
    t.string   "activity_type"
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "source_id"
    t.string   "source_type"
    t.string   "action",                                                          :null => false
    t.boolean  "public",                                       :default => false, :null => false
    t.decimal  "lat",           :precision => 11, :scale => 9,                    :null => false
    t.decimal  "lng",           :precision => 12, :scale => 9,                    :null => false
    t.datetime "created_at"
  end

  add_index "activity_items", ["actor_id", "activity_type"], :name => "index_activity_items_on_actor_id_and_activity_type"

  create_table "devices", :force => true do |t|
    t.string   "udid",          :null => false
    t.integer  "user_id",       :null => false
    t.string   "app_version",   :null => false
    t.string   "os_id",         :null => false
    t.string   "platform",      :null => false
    t.string   "token"
    t.datetime "last_login_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["udid"], :name => "index_devices_on_udid", :unique => true

  create_table "duplicate_places", :force => true do |t|
    t.integer  "place_1_id"
    t.integer  "place_2_id"
    t.decimal  "name_distance",    :precision => 9, :scale => 2
    t.decimal  "address_distance", :precision => 9, :scale => 2
    t.decimal  "geo_distance",     :precision => 9, :scale => 2
    t.decimal  "total_distance",   :precision => 9, :scale => 2
    t.integer  "status",                                         :default => 0, :null => false
    t.integer  "canonical_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "duplicate_places", ["place_1_id", "place_2_id"], :name => "index_duplicate_places_on_place_1_id_and_place_2_id", :unique => true

  create_table "facebook_accounts", :force => true do |t|
    t.integer  "facebook_id",  :limit => 8, :null => false
    t.string   "access_token",              :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name"
    t.string   "gender"
    t.string   "email"
    t.string   "locale"
    t.integer  "user_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_accounts", ["facebook_id"], :name => "index_facebook_accounts_on_facebook_id", :unique => true

  create_table "facebook_places", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.decimal  "lat",         :precision => 11, :scale => 9, :null => false
    t.decimal  "lng",         :precision => 12, :scale => 9, :null => false
    t.string   "facebook_id",                                :null => false
    t.integer  "place_id",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_places", ["facebook_id"], :name => "index_facebook_places_on_facebook_id", :unique => true
  add_index "facebook_places", ["lat", "lng"], :name => "index_facebook_places_on_lat_and_lng"
  add_index "facebook_places", ["place_id"], :name => "index_facebook_places_on_place_id"

  create_table "foursquare_places", :force => true do |t|
    t.string   "name"
    t.string   "categories"
    t.string   "address"
    t.string   "cross_street"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.decimal  "lat",           :precision => 11, :scale => 9, :null => false
    t.decimal  "lng",           :precision => 12, :scale => 9, :null => false
    t.string   "phone"
    t.string   "twitter"
    t.string   "foursquare_id",                                :null => false
    t.integer  "place_id",                                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "foursquare_places", ["foursquare_id"], :name => "index_foursquare_places_on_foursquare_id", :unique => true
  add_index "foursquare_places", ["lat", "lng"], :name => "index_foursquare_places_on_lat_and_lng"
  add_index "foursquare_places", ["place_id"], :name => "index_foursquare_places_on_place_id"

  create_table "google_places", :force => true do |t|
    t.string   "cid",                                           :null => false
    t.integer  "place_id",                                      :null => false
    t.string   "name"
    t.string   "listing_type"
    t.string   "street_address"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.text     "address"
    t.string   "phone_number"
    t.decimal  "lat",            :precision => 11, :scale => 9, :null => false
    t.decimal  "lng",            :precision => 12, :scale => 9, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "google_places", ["cid"], :name => "index_google_places_on_cid", :unique => true
  add_index "google_places", ["lat", "lng"], :name => "index_google_places_on_lat_and_lng"
  add_index "google_places", ["place_id"], :name => "index_google_places_on_place_id"

  create_table "gowalla_places", :force => true do |t|
    t.string   "name",                                          :null => false
    t.string   "street_address"
    t.string   "region"
    t.string   "locality"
    t.string   "iso3166"
    t.integer  "radius_meters"
    t.decimal  "lat",            :precision => 11, :scale => 9, :null => false
    t.decimal  "lng",            :precision => 12, :scale => 9, :null => false
    t.string   "phone_number"
    t.string   "categories"
    t.string   "gowalla_id",                                    :null => false
    t.string   "foursquare_id"
    t.integer  "place_id",                                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gowalla_places", ["gowalla_id"], :name => "index_gowalla_places_on_gowalla_id", :unique => true
  add_index "gowalla_places", ["lat", "lng"], :name => "index_gowalla_places_on_lat_and_lng"
  add_index "gowalla_places", ["place_id"], :name => "index_gowalla_places_on_place_id"

  create_table "password_accounts", :force => true do |t|
    t.string   "login",            :null => false
    t.string   "crypted_password", :null => false
    t.string   "password_salt",    :null => false
    t.integer  "user_id",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "password_accounts", ["login"], :name => "index_password_accounts_on_login", :unique => true

  create_table "place_searches", :force => true do |t|
    t.string   "query",                                     :null => false
    t.string   "position"
    t.decimal  "lat",        :precision => 11, :scale => 9
    t.decimal  "lng",        :precision => 12, :scale => 9
    t.integer  "result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", :force => true do |t|
    t.string   "full_name",                                                           :null => false
    t.string   "full_address"
    t.string   "clean_name",                                                          :null => false
    t.string   "clean_address"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.string   "phone_number"
    t.string   "source"
    t.decimal  "lat",               :precision => 11, :scale => 9
    t.decimal  "lng",               :precision => 12, :scale => 9
    t.text     "image_thumbnail"
    t.string   "image_file_name"
    t.datetime "image_updated_at"
    t.string   "image_attribution"
    t.integer  "wishlist_count",                                   :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "image_processing",                                 :default => false, :null => false
    t.boolean  "delta",                                            :default => true,  :null => false
    t.integer  "canonical_id",                                     :default => 0,     :null => false
  end

  add_index "places", ["canonical_id"], :name => "index_places_on_canonical_id"
  add_index "places", ["lat", "lng"], :name => "index_places_on_lat_and_lng"

  create_table "preview_signups", :force => true do |t|
    t.string   "email",                         :null => false
    t.integer  "referral_count", :default => 0, :null => false
    t.integer  "test",           :default => 0, :null => false
    t.integer  "referrer_id"
    t.datetime "created_at"
  end

  add_index "preview_signups", ["email"], :name => "index_preview_signups_on_email", :unique => true

  create_table "users", :force => true do |t|
    t.string   "full_name"
    t.string   "email"
    t.datetime "current_login_at"
    t.integer  "login_count",         :default => 0, :null => false
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

  create_table "wishlist_items", :force => true do |t|
    t.integer  "user_id",                                    :null => false
    t.integer  "item_id",                                    :null => false
    t.string   "item_type",                                  :null => false
    t.decimal  "lat",         :precision => 11, :scale => 9
    t.decimal  "lng",         :precision => 12, :scale => 9
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_type"
    t.integer  "source_id"
    t.datetime "deleted_at"
  end

  add_index "wishlist_items", ["user_id", "item_type", "item_id"], :name => "index_wishlist_items_on_user_id_and_item_type_and_item_id", :unique => true

  create_table "yelp_places", :force => true do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "address"
    t.string   "city"
    t.string   "state_code"
    t.string   "country_code"
    t.string   "postal_code"
    t.string   "cross_streets"
    t.string   "display_address"
    t.string   "neighborhoods"
    t.string   "categories"
    t.integer  "geo_accuracy"
    t.decimal  "lat",             :precision => 11, :scale => 9, :null => false
    t.decimal  "lng",             :precision => 12, :scale => 9, :null => false
    t.string   "yelp_id",                                        :null => false
    t.integer  "place_id",                                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "yelp_places", ["lat", "lng"], :name => "index_yelp_places_on_lat_and_lng"
  add_index "yelp_places", ["place_id"], :name => "index_yelp_places_on_place_id"
  add_index "yelp_places", ["yelp_id"], :name => "index_yelp_places_on_yelp_id", :unique => true

end
