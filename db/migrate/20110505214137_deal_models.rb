class DealModels < ActiveRecord::Migration
  def self.up
    create_table "deal_templates" do |t|
      t.string :name, :null => false
      t.text :description
      t.text :rejection_reasoning
      t.integer :position
      t.integer :status, :limit => 4, :null => false, :default => 0
      t.integer :deal_count, :null => false, :default => 0
      t.integer :discount_percentage, :null => false, :default => 0
      t.integer :start_time, :null => false, :default => 0, :limit => 4
      t.integer :end_time, :null => false, :default => 0, :limit => 4
      t.integer :average_spend, :null => false, :default => 0
      t.integer :business_id, :null => false
      t.integer :cost_cents
      t.timestamps
    end
    add_index "deal_templates", :business_id
    
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
      t.integer :average_spend, :null => false, :default => 0
      t.datetime :removed_at
      t.datetime :approved_at
      t.timestamps
    end
    add_index "deal_events", "business_id"
    add_index "deal_events", ["starts_at", "ends_at"]
  end

  def self.down
    drop_table "deal_templates"
    drop_table "deal_events"
  end
end
