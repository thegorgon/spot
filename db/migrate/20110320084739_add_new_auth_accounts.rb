class AddNewAuthAccounts < ActiveRecord::Migration
  def self.up
    create_table :password_accounts do |t|
      t.string :login, :null => false
      t.string :crypted_password, :null => false
      t.string :password_salt, :null => false
      t.integer :user_id, :null => false
      t.timestamps
    end
    add_index :password_accounts, :login, :unique => true
    
    create_table :facebook_accounts do |t|
      t.integer :facebook_id, :limit => 8, :null => false
      t.string  :access_token, :null => false
      t.string  :first_name
      t.string  :last_name
      t.string  :name
      t.string  :gender
      t.string  :email
      t.string  :locale
      t.integer :user_id, :null => false
      t.timestamps
    end
    add_index :facebook_accounts, :facebook_id, :unique => true
  end

  def self.down
    drop_table :password_accounts
    drop_table :facebook_accounts
  end
end
