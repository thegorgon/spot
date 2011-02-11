class CreateUsersAndDevices < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.datetime :current_login_at
      t.integer :login_count, :null => false, :default => 0
      t.string :persistence_token
      t.string :single_access_token
      t.string :perishable_token
      t.timestamps
    end
    add_index :users, :persistence_token
    
    create_table :devices do |t|
      t.string :udid, :null => false
      t.integer :user_id, :null => false
      t.string :app_version, :null => false
      t.string :os_id, :null => false
      t.string :platform, :null => false
      t.string :token
      t.datetime :last_login_at
      t.timestamps
    end
    add_index :devices, :udid, :unique => true
  end

  def self.down
    drop_table :users
    drop_table :devices
  end
end
