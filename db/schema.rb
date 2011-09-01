# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20110901200531) do

  create_table "acquisition_campaigns", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "acquisition_cohorts", :force => true do |t|
    t.integer  "acquisition_source_id"
    t.string   "acquisition_campaign_id",                :null => false
    t.integer  "member_clicks",           :default => 0, :null => false
    t.integer  "nonmember_clicks",        :default => 0, :null => false
    t.integer  "emails",                  :default => 0, :null => false
    t.integer  "applications",            :default => 0, :null => false
    t.integer  "signups",                 :default => 0, :null => false
    t.integer  "memberships",             :default => 0, :null => false
    t.integer  "annual_subscribers",      :default => 0, :null => false
    t.integer  "monthly_subscribers",     :default => 0, :null => false
    t.integer  "registrations",           :default => 0, :null => false
    t.integer  "unsubscriptions",         :default => 0, :null => false
    t.date     "date",                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "acquisition_cohorts", ["acquisition_source_id", "date", "acquisition_campaign_id"], :name => "index_ac_on_source_date_and_campaign"

  create_table "acquisition_events", :force => true do |t|
    t.integer  "email_subscriptions_id"
    t.integer  "user_id"
    t.integer  "event_id"
    t.integer  "acquisition_source_id"
    t.integer  "original_acquisition_source_id"
    t.string   "locale"
    t.string   "value"
    t.integer  "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "acquisition_events", ["event_id", "created_at"], :name => "index_acquisition_events_on_event_id_and_created_at"

  create_table "acquisition_sources", :force => true do |t|
    t.string   "name"
    t.string   "acquisition_campaign_id",                :null => false
    t.integer  "member_clicks",           :default => 0, :null => false
    t.integer  "nonmember_clicks",        :default => 0, :null => false
    t.integer  "emails",                  :default => 0, :null => false
    t.integer  "applications",            :default => 0, :null => false
    t.integer  "signups",                 :default => 0, :null => false
    t.integer  "memberships",             :default => 0, :null => false
    t.integer  "annual_subscribers",      :default => 0, :null => false
    t.integer  "monthly_subscribers",     :default => 0, :null => false
    t.integer  "registrations",           :default => 0, :null => false
    t.integer  "unsubscriptions",         :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "acquisition_sources", ["acquisition_campaign_id"], :name => "index_acquisition_sources_on_acquisition_campaign_id"

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

  create_table "app_settings", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_settings", ["key"], :name => "index_app_settings_on_key"

  create_table "blog_posts", :force => true do |t|
    t.string "tumblr_id", :null => false
    t.string "slug",      :null => false
  end

  add_index "blog_posts", ["slug"], :name => "index_blog_posts_on_slug", :unique => true

  create_table "business_accounts", :force => true do |t|
    t.integer  "user_id",                             :null => false
    t.string   "first_name",                          :null => false
    t.string   "last_name",                           :null => false
    t.string   "email",                               :null => false
    t.string   "title",                               :null => false
    t.string   "phone",                               :null => false
    t.integer  "businesses_count",     :default => 0, :null => false
    t.integer  "max_businesses_count",                :null => false
    t.datetime "verified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notification_flags",   :default => 0, :null => false
  end

  add_index "business_accounts", ["user_id"], :name => "index_business_accounts_on_user_id"

  create_table "businesses", :force => true do |t|
    t.integer  "place_id",                           :null => false
    t.integer  "business_account_id",                :null => false
    t.integer  "average_spend",       :default => 0, :null => false
    t.datetime "verified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "businesses", ["business_account_id", "place_id"], :name => "index_businesses_on_business_account_id_and_place_id", :unique => true

  create_table "cities", :force => true do |t|
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

  create_table "credit_cards", :force => true do |t|
    t.integer  "user_id"
    t.string   "cardholder_name"
    t.string   "token"
    t.string   "card_type"
    t.string   "bin"
    t.string   "last_4"
    t.integer  "position"
    t.integer  "expiration_month"
    t.integer  "expiration_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_cards", ["token"], :name => "index_credit_cards_on_token", :unique => true
  add_index "credit_cards", ["user_id"], :name => "index_credit_cards_on_user_id"

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

  create_table "email_subscriptions", :force => true do |t|
    t.string   "email",                                        :null => false
    t.integer  "city_id"
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "unsubscription_flags",  :default => 0,         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "data"
    t.integer  "acquisition_source_id"
    t.string   "source",                :default => "website", :null => false
  end

  add_index "email_subscriptions", ["email"], :name => "index_email_subscriptions_on_email", :unique => true

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

  create_table "invitation_codes", :force => true do |t|
    t.integer "user_id"
    t.string  "code",                             :null => false
    t.integer "invitation_count", :default => -1, :null => false
    t.integer "claimed_count",    :default => 0,  :null => false
    t.integer "signup_count",     :default => 0,  :null => false
  end

  add_index "invitation_codes", ["code"], :name => "index_invitation_codes_on_code", :unique => true

  create_table "membership_applications", :force => true do |t|
    t.integer  "user_id",               :null => false
    t.integer  "city_id",               :null => false
    t.string   "invitation_code",       :null => false
    t.text     "survey",                :null => false
    t.datetime "approved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "acquisition_source_id"
  end

  add_index "membership_applications", ["city_id", "user_id"], :name => "index_membership_applications_on_city_id_and_user_id", :unique => true

  create_table "memberships", :force => true do |t|
    t.integer  "user_id",                              :null => false
    t.string   "payment_method_type",                  :null => false
    t.integer  "payment_method_id",                    :null => false
    t.integer  "city_id",                              :null => false
    t.integer  "status",                :default => 0, :null => false
    t.datetime "expires_at"
    t.datetime "starts_at",                            :null => false
    t.datetime "created_at",                           :null => false
    t.integer  "acquisition_source_id"
  end

  add_index "memberships", ["user_id"], :name => "index_memberships_on_user_id"

  create_table "mobile_apps", :force => true do |t|
    t.string  "name",                        :null => false
    t.string  "location",                    :null => false
    t.string  "store_id",                    :null => false
    t.string  "store",                       :null => false
    t.boolean "live",     :default => false, :null => false
  end

  add_index "mobile_apps", ["store", "location"], :name => "index_mobile_apps_on_store_and_location", :unique => true

  create_table "password_accounts", :force => true do |t|
    t.string   "login",            :null => false
    t.string   "crypted_password", :null => false
    t.string   "password_salt",    :null => false
    t.integer  "user_id",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "password_accounts", ["login"], :name => "index_password_accounts_on_login", :unique => true

  create_table "place_notes", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.integer  "place_id",                  :null => false
    t.text     "content",                   :null => false
    t.integer  "status",     :default => 0, :null => false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "place_notes", ["place_id"], :name => "index_place_notes_on_place_id"
  add_index "place_notes", ["user_id"], :name => "index_place_notes_on_user_id"

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
    t.string   "email",                             :null => false
    t.integer  "referral_count", :default => 0,     :null => false
    t.integer  "test",           :default => 0,     :null => false
    t.integer  "referrer_id"
    t.datetime "created_at"
    t.boolean  "emailed",        :default => false, :null => false
    t.string   "interest",                          :null => false
    t.string   "value",          :default => "",    :null => false
  end

  add_index "preview_signups", ["interest", "email"], :name => "index_preview_signups_on_interest_and_email", :unique => true

  create_table "promo_codes", :force => true do |t|
    t.string   "name",                               :null => false
    t.text     "description",                        :null => false
    t.string   "code",                               :null => false
    t.boolean  "acts_as_payment", :default => false, :null => false
    t.integer  "duration",        :default => -1,    :null => false
    t.integer  "user_count",      :default => -1,    :null => false
    t.integer  "use_count",       :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promo_codes", ["code"], :name => "index_promo_codes_on_code", :unique => true

  create_table "promotion_codes", :force => true do |t|
    t.string   "type"
    t.integer  "owner_id"
    t.integer  "event_id"
    t.integer  "business_id", :null => false
    t.string   "code",        :null => false
    t.text     "parameters"
    t.date     "date",        :null => false
    t.integer  "start_time",  :null => false
    t.integer  "end_time",    :null => false
    t.datetime "issued_at"
    t.datetime "redeemed_at"
    t.datetime "locked_at"
  end

  add_index "promotion_codes", ["business_id", "date", "code"], :name => "index_deal_codes_on_business_id_and_date_and_code", :unique => true
  add_index "promotion_codes", ["event_id"], :name => "index_deal_codes_on_deal_event_id"
  add_index "promotion_codes", ["owner_id", "date"], :name => "index_deal_codes_on_owner_id_and_date"

  create_table "promotion_events", :force => true do |t|
    t.string   "type",                                                        :null => false
    t.integer  "template_id"
    t.integer  "business_id",                                                 :null => false
    t.string   "name",                                                        :null => false
    t.text     "description"
    t.integer  "count",                                        :default => 0, :null => false
    t.integer  "sale_count",                                   :default => 0, :null => false
    t.integer  "cost_cents"
    t.text     "parameters"
    t.date     "date",                                                        :null => false
    t.integer  "start_time",                                                  :null => false
    t.integer  "end_time",                                                    :null => false
    t.datetime "removed_at"
    t.datetime "approved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "lat",           :precision => 11, :scale => 9,                :null => false
    t.decimal  "lng",           :precision => 12, :scale => 9,                :null => false
    t.integer  "place_id",                                                    :null => false
    t.string   "short_summary"
  end

  add_index "promotion_events", ["business_id", "date"], :name => "index_deal_events_on_business_id_and_date"

  create_table "promotion_templates", :force => true do |t|
    t.string   "type",                                   :null => false
    t.integer  "business_id",                            :null => false
    t.string   "name",                                   :null => false
    t.text     "description"
    t.text     "parameters"
    t.text     "rejection_reasoning"
    t.integer  "position"
    t.integer  "status",              :default => 0,     :null => false
    t.integer  "count",               :default => 0,     :null => false
    t.integer  "start_time",          :default => 0,     :null => false
    t.integer  "end_time",            :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "short_summary"
    t.boolean  "designed_by_spot",    :default => false, :null => false
    t.integer  "place_id",                               :null => false
  end

  add_index "promotion_templates", ["business_id"], :name => "index_deal_templates_on_business_id"

  create_table "short_urls", :force => true do |t|
    t.string   "url"
    t.integer  "visits",        :default => 0, :null => false
    t.datetime "last_visit_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "short_urls", ["url"], :name => "index_short_urls_on_url", :unique => true

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "credit_card_id"
    t.string   "plan_id"
    t.string   "promo_code"
    t.string   "braintree_id"
    t.integer  "price_cents"
    t.string   "status"
    t.integer  "billing_day_of_month"
    t.integer  "billing_period"
    t.datetime "billing_starts_at"
    t.datetime "cancelled_at"
    t.datetime "created_at"
    t.integer  "acquisition_source_id"
  end

  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "user_events", :force => true do |t|
    t.integer  "user_id",    :default => -1, :null => false
    t.integer  "event_id",                   :null => false
    t.string   "value",      :default => "", :null => false
    t.string   "locale"
    t.datetime "created_at",                 :null => false
  end

  add_index "user_events", ["event_id", "created_at"], :name => "index_user_events_on_event_id_and_created_at"
  add_index "user_events", ["user_id", "created_at"], :name => "index_user_events_on_user_id_and_created_at"

  create_table "users", :force => true do |t|
    t.datetime "current_login_at"
    t.integer  "login_count",           :default => 0,     :null => false
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "locale"
    t.boolean  "admin",                 :default => false, :null => false
    t.string   "location"
    t.string   "customer_id"
    t.integer  "city_id"
    t.integer  "acquisition_source_id"
  end

  add_index "users", ["city_id"], :name => "index_users_on_city_id"
  add_index "users", ["customer_id"], :name => "index_users_on_customer_id", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
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

  add_index "wishlist_items", ["user_id", "item_type", "item_id"], :name => "index_wishlist_items_on_user_id_and_item_type_and_item_id"

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
