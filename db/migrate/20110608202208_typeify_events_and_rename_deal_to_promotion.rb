class TypeifyEventsAndRenameDealToPromotion < ActiveRecord::Migration
  def self.up
    drop_table :deal_events
    drop_table :deal_templates
    drop_table :deal_codes
    
    create_table "promotion_codes" do |t|
      t.string   "type"
      t.integer  "owner_id"
      t.integer  "event_id"
      t.integer  "business_id",         :null => false
      t.string   "code",                :null => false
      t.text     "parameters"
      t.date     "date",                :null => false
      t.integer  "start_time",          :null => false
      t.integer  "end_time",            :null => false
      t.datetime "issued_at"
      t.datetime "redeemed_at"
      t.datetime "locked_at"
    end
    
    add_index "promotion_codes", ["business_id", "date", "code"], :name => "index_deal_codes_on_business_id_and_date_and_code", :unique => true
    add_index "promotion_codes", ["event_id"], :name => "index_deal_codes_on_deal_event_id"
    add_index "promotion_codes", ["owner_id", "date"], :name => "index_deal_codes_on_owner_id_and_date"
    
    create_table "promotion_events" do |t|
      t.string   "type",                               :null => false
      t.integer  "template_id"
      t.integer  "business_id",                          :null => false
      t.string   "name",                                 :null => false
      t.text     "description"
      t.integer  "count",                 :default => 0, :null => false
      t.integer  "sale_count",            :default => 0, :null => false
      t.integer  "cost_cents"
      t.text     "parameters"
      t.date     "date",                                 :null => false
      t.integer  "start_time",                           :null => false
      t.integer  "end_time",                             :null => false
      t.datetime "removed_at"
      t.datetime "approved_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    add_index "promotion_events", ["business_id", "date"], :name => "index_deal_events_on_business_id_and_date"
    
    create_table "promotion_templates" do |t|
      t.string   "type",                               :null => false
      t.integer  "business_id",                        :null => false
      t.string   "name",                               :null => false
      t.text     "description"
      t.integer  "cost_cents"
      t.text     "parameters"
      t.text     "rejection_reasoning"
      t.integer  "position"
      t.integer  "status",              :default => 0, :null => false
      t.integer  "count",          :default => 0, :null => false
      t.integer  "start_time",          :default => 0, :null => false
      t.integer  "end_time",            :default => 0, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "promotion_templates", ["business_id"], :name => "index_deal_templates_on_business_id"
  end

  def self.down
    create_table "deal_codes", :force => true do |t|
      t.integer  "owner_id"
      t.integer  "deal_event_id"
      t.integer  "business_id",         :null => false
      t.string   "code",                :null => false
      t.integer  "discount_percentage", :null => false
      t.date     "date",                :null => false
      t.integer  "start_time",          :null => false
      t.integer  "end_time",            :null => false
      t.datetime "issued_at"
      t.datetime "redeemed_at"
      t.datetime "locked_at"
    end
    
    add_index "deal_codes", ["business_id", "date", "code"], :name => "index_deal_codes_on_business_id_and_date_and_code", :unique => true
    add_index "deal_codes", ["deal_event_id"], :name => "index_deal_codes_on_deal_event_id"
    add_index "deal_codes", ["owner_id", "date"], :name => "index_deal_codes_on_owner_id_and_date"
    
    create_table "deal_events", :force => true do |t|
      t.integer  "deal_template_id"
      t.integer  "business_id",                          :null => false
      t.string   "name",                                 :null => false
      t.text     "description"
      t.integer  "deal_count",            :default => 0, :null => false
      t.integer  "discount_percentage",   :default => 0, :null => false
      t.integer  "start_time",                           :null => false
      t.integer  "end_time",                             :null => false
      t.date     "date",                                 :null => false
      t.integer  "sale_count",            :default => 0, :null => false
      t.integer  "cost_cents"
      t.integer  "average_spend", :default => 0, :null => false
      t.datetime "removed_at"
      t.datetime "approved_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    add_index "deal_events", ["business_id", "date"], :name => "index_deal_events_on_business_id_and_date"
    
    create_table "deal_templates", :force => true do |t|
      t.string   "name",                               :null => false
      t.text     "description"
      t.text     "rejection_reasoning"
      t.integer  "position"
      t.integer  "status",              :default => 0, :null => false
      t.integer  "deal_count",          :default => 0, :null => false
      t.integer  "discount_percentage", :default => 0, :null => false
      t.integer  "start_time",          :default => 0, :null => false
      t.integer  "end_time",            :default => 0, :null => false
      t.integer  "average_spend",       :default => 0, :null => false
      t.integer  "business_id",                        :null => false
      t.integer  "cost_cents"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    add_index "deal_templates", ["business_id"], :name => "index_deal_templates_on_business_id"
      
    drop_table :promotion_events
    drop_table :promotion_templates
    drop_table :promotion_codes
  end
end
