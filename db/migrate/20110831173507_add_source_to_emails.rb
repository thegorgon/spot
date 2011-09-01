class AddSourceToEmails < ActiveRecord::Migration
  def self.up
    add_column :email_subscriptions, :source, :string, :null => false, :default => "website"
  end

  def self.down
    remove_column :email_subscriptions, :source, :string
  end
end
