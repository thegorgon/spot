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

ActiveRecord::Schema.define(:version => 20110211075715) do

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

  create_table "places", :force => true do |t|
    t.string   "full_name",                                                       :null => false
    t.string   "full_address"
    t.string   "clean_name",                                                      :null => false
    t.string   "clean_address"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.string   "phone_number"
    t.string   "source"
    t.integer  "status",                                           :default => 0, :null => false
    t.decimal  "lat",               :precision => 11, :scale => 9
    t.decimal  "lng",               :precision => 12, :scale => 9
    t.text     "image_thumbnail"
    t.string   "image_file_name"
    t.datetime "image_updated_at"
    t.string   "image_attribution"
    t.integer  "wishlist_count",                                   :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "places", ["lat", "lng"], :name => "index_places_on_lat_and_lng"

  create_table "preview_signups", :force => true do |t|
    t.string  "email",                         :null => false
    t.integer "referral_count", :default => 0, :null => false
    t.integer "test",           :default => 0, :null => false
    t.integer "referrer_id"
  end

  add_index "preview_signups", ["email"], :name => "index_preview_signups_on_email", :unique => true

  create_table "users", :force => true do |t|
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
    t.integer  "user_id",                                   :null => false
    t.integer  "item_id",                                   :null => false
    t.string   "item_type",                                 :null => false
    t.decimal  "lat",        :precision => 11, :scale => 9
    t.decimal  "lng",        :precision => 12, :scale => 9
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wishlist_items", ["user_id", "item_type", "item_id"], :name => "index_wishlist_items_on_user_id_and_item_type_and_item_id", :unique => true

end
