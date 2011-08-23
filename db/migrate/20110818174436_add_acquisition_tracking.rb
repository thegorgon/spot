class AddAcquisitionTracking < ActiveRecord::Migration
  def self.up
    add_column :email_subscriptions, :acquisition_source_id, :integer
    add_column :users, :acquisition_source_id, :integer
    add_column :membership_applications, :acquisition_source_id, :integer
    add_column :memberships, :acquisition_source_id, :integer
    add_column :subscriptions, :acquisition_source_id, :integer
    
    create_table :acquisition_campaigns do |t|
      t.string :name
      t.string :category
      t.timestamps
    end
    
    create_table :acquisition_sources do |t|
      t.string  :name
      t.string  :acquisition_campaign_id, :null => false
      t.integer :member_clicks, :null => false, :default => 0
      t.integer :nonmember_clicks, :null => false, :default => 0
      t.integer :emails, :null => false, :default => 0
      t.integer :applications, :null => false, :default => 0
      t.integer :signups, :null => false, :default => 0
      t.integer :memberships, :null => false, :default => 0
      t.integer :annual_subscribers, :null => false, :default => 0
      t.integer :monthly_subscribers, :null => false, :default => 0
      t.integer :registrations, :null => false, :default => 0
      t.integer :unsubscriptions, :null => false, :default => 0
      t.timestamps
    end
    add_index :acquisition_sources, :acquisition_campaign_id
    
    create_table :acquisition_cohorts do |t|
      t.integer :acquisition_source_id
      t.string  :acquisition_campaign_id, :null => false
      t.integer :member_clicks, :null => false, :default => 0
      t.integer :nonmember_clicks, :null => false, :default => 0
      t.integer :emails, :null => false, :default => 0
      t.integer :applications, :null => false, :default => 0
      t.integer :signups, :null => false, :default => 0
      t.integer :memberships, :null => false, :default => 0
      t.integer :annual_subscribers, :null => false, :default => 0
      t.integer :monthly_subscribers, :null => false, :default => 0
      t.integer :registrations, :null => false, :default => 0
      t.integer :unsubscriptions, :null => false, :default => 0
      t.date    :date, :null => false
      t.timestamps
    end
    add_index :acquisition_cohorts, [:acquisition_source_id, :date, :acquisition_campaign_id], :name => "index_ac_on_source_date_and_campaign"
    
    create_table :acquisition_events do |t|
      t.integer :email_subscriptions_id
      t.integer :user_id
      t.integer :event_id
      t.integer :acquisition_source_id
      t.integer :original_acquisition_source_id
      t.string  :locale
      t.string  :value
      t.column :ip, 'integer unsigned'
      t.timestamps
    end
    add_index :acquisition_events, [:event_id, :created_at]
  end

  def self.down
    drop_table :acquisition_campaigns
    drop_table :acquisition_sources
    drop_table :acquisition_cohorts
    drop_table :acquisition_events
    
    remove_column :email_subscriptions, :acquisition_source_id    
    remove_column :users, :acquisition_source_id    
    remove_column :membership_applications, :acquisition_source_id    
    remove_column :memberships, :acquisition_source_id    
    remove_column :subscriptions, :acquisition_source_id    
  end
end
