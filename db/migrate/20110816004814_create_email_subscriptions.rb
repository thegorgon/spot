class CreateEmailSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :email_subscriptions do |t|
      t.string :email, :null => false
      t.integer :city_id
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.integer :unsubscription_flags, :null => false, :default => 0
      t.timestamps
    end
    add_index :email_subscriptions, :email, :unique => true
    
    execute "INSERT INTO email_subscriptions (email, first_name, last_name) 
                                        (SELECT pe.email, pe.first_name, pe.last_name FROM placepop_emails pe
                                          LEFT JOIN email_subscriptions es ON es.email = pe.email 
                                          WHERE es.id IS NULL AND pe.email IS NOT NULL AND pe.email <> '')"
    execute "INSERT INTO email_subscriptions (email, first_name, last_name, city_id, user_id) 
                                        (SELECT u.email, u.first_name, u.last_name, u.city_id, u.id as user_id FROM users u
                                          LEFT JOIN email_subscriptions es ON es.email = u.email 
                                          WHERE es.id IS NULL AND u.email IS NOT NULL AND u.email <> '')"
      
    execute "UPDATE email_subscriptions SET unsubscription_flags = ~unsubscription_flags WHERE email IN (SELECT address FROM blocked_emails)"
    
    drop_table :placepop_emails
    drop_table :blocked_emails
    remove_column :users, :notification_flags
  end

  def self.down
    add_column :users, :notification_flags, :integer, :null => false, :default => 0
    
    create_table "blocked_emails", :force => true do |t|
      t.string   "address",                         :null => false
      t.string   "source",     :default => "other", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    add_index "blocked_emails", ["address"], :name => "index_blocked_emails_on_address", :unique => true
    
    create_table "placepop_emails", :force => true do |t|
      t.string "email",                      :null => false
      t.string "first_name",                 :null => false
      t.string "last_name",  :default => "", :null => false
    end
      
    drop_table :email_subscriptions
  end
end
