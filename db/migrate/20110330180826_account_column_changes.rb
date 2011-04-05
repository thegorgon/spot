class AccountColumnChanges < ActiveRecord::Migration
  def self.up
    add_column :password_accounts, :first_name, :string
    add_column :password_accounts, :last_name, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    remove_column :users, :full_name
    add_column :users, :locale, :string, :null => false, :default => "en-US"
    add_column :users, :admin, :boolean, :null => false, :default => 0
    add_index :users, :email, :unique => true
  end

  def self.down
    remove_column :password_accounts, :first_name, :last_name
    remove_column :users, :first_name, :last_name
    add_column :users, :full_name, :string
    remove_column :users, :locale, :admin
    remove_index :users, :email
  end
end
