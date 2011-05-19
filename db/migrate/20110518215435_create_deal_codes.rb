class CreateDealCodes < ActiveRecord::Migration
  def self.up
    drop_table "deal_events"
    create_table "deal_events" do |t|
      t.integer :deal_template_id
      t.integer :business_id, :null => false
      t.string :name, :null => false
      t.text :description
      t.integer :deal_count, :null => false, :default => 0
      t.integer :discount_percentage, :null => false, :default => 0
      t.integer :start_time, :null => false
      t.integer :end_time, :null => false
      t.date    :date, :null => false
      t.integer :sale_count, :null => false, :default => 0
      t.integer :cost_cents
      t.integer :estimated_cents_value, :null => false, :default => 0
      t.datetime :removed_at
      t.datetime :approved_at
      t.timestamps
    end
    add_index "deal_events", ["business_id", "date"]

    create_table :deal_codes do |t|
      t.integer :owner_id
      t.integer :deal_event_id
      t.string :code, :null => false
      t.integer :discount_percentage, :null => false
      t.date :date, :null => false
      t.integer :start_time, :null => false, :limit => 4
      t.integer :end_time, :null => false, :limit => 4
      t.datetime :issued_at
      t.datetime :redeemed_at
      t.datetime :locked_at
    end
    add_index :deal_codes, [:owner_id, :date]
    add_index :deal_codes, [:deal_event_id, :date]
  end

  def self.down
    drop_table "deal_events"
    create_table "deal_events" do |t|
      t.integer :deal_template_id
      t.integer :business_id, :null => false
      t.string :name, :null => false
      t.text :description
      t.integer :deal_count, :null => false, :default => 0
      t.integer :discount_percentage, :null => false, :default => 0
      t.datetime :starts_at, :null => false
      t.datetime :ends_at, :null => false
      t.integer :sale_count, :null => false, :default => 0
      t.integer :cost_cents
      t.integer :estimated_cents_value, :null => false, :default => 0
      t.datetime :removed_at
      t.datetime :approved_at
      t.timestamps
    end
    add_index "deal_events", "business_id"
    add_index "deal_events", ["starts_at", "ends_at"]
    
    drop_table :deal_codes
  end
end
