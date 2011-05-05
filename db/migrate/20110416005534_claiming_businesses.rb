class ClaimingBusinesses < ActiveRecord::Migration
  def self.up
    create_table :business_accounts do |t|
      t.integer :user_id, :null => false
      t.string  :first_name, :null => false
      t.string  :last_name, :null => false
      t.string  :email, :null => false
      t.string  :title, :null => false
      t.string  :phone, :null => false
      t.integer :businesses_count, :null => false, :default => 0
      t.integer :max_businesses_count, :null => false
      t.datetime :verified_at
      t.timestamps
    end
    add_index :business_accounts, :user_id
    
    create_table :businesses do |t|
      t.integer :place_id, :null => false
      t.integer :business_account_id, :null => false
      t.integer :average_spend, :null => false, :default => 0
      t.datetime :verified_at
      t.timestamps
    end
    add_index :businesses, [:business_account_id, :place_id], :unique => true
  end

  def self.down
    drop_table :business_accounts
    drop_table :businesses
  end
end
