class AddEmailNotificationsToBizAccounts < ActiveRecord::Migration
  def self.up
    add_column :business_accounts, :notification_flags, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :business_accounts, :notification_flags
  end
end
