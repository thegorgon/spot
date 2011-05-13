class AddNotificationFlags < ActiveRecord::Migration
  def self.up
    add_column :users, :notification_flags, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :users, :notification_flags
  end
end
