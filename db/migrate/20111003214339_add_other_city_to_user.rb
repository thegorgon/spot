class AddOtherCityToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :other_city, :string    
    execute("UPDATE users SET users.other_city = (SELECT other_city FROM email_subscriptions WHERE email_subscriptions.email = users.email) WHERE users.email IS NOT NULL")
  end

  def self.down
    remove_column :users, :other_city
  end
end
