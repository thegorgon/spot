class UserEventsAndSettings < ActiveRecord::Migration
  def self.up
    create_table "user_events" do |t|
      t.integer :user_id, :null => false, :default => -1
      t.integer :event_id, :null => false
      t.string  :value, :null => false, :default => ""
      t.string  :locale
      t.datetime :created_at, :null => false
    end
    add_index :user_events, [:user_id, :created_at]
    add_index :user_events, [:event_id, :created_at]
    
    create_table "app_settings" do |t|
      t.string :key
      t.string :value
      t.string :category
      t.timestamps
    end
    add_index "app_settings", "key", "unique" => true
  end

  def self.down
    drop_table "user_events"
    drop_table "app_settings"
  end
end
