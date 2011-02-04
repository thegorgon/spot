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

ActiveRecord::Schema.define(:version => 20110131201616) do

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
    t.string   "full_name",                                                      :null => false
    t.string   "full_address"
    t.string   "clean_name",                                                     :null => false
    t.string   "clean_address"
    t.string   "phone_number"
    t.string   "source"
    t.integer  "status",                                          :default => 0, :null => false
    t.decimal  "lat",              :precision => 11, :scale => 9
    t.decimal  "lng",              :precision => 12, :scale => 9
    t.text     "image_thumbnail"
    t.string   "image_file_name"
    t.datetime "image_updated_at"
    t.integer  "wishlist_count",                                  :default => 0, :null => false
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

end
