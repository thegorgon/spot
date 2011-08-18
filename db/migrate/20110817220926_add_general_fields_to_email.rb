class AddGeneralFieldsToEmail < ActiveRecord::Migration
  def self.up
    add_column :email_subscriptions, :data, :text
  end

  def self.down
    remove_column :email_subscriptions, :data
  end
end
