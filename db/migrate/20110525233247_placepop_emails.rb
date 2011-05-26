class PlacepopEmails < ActiveRecord::Migration
  def self.up
    create_table :placepop_emails do |t|
      t.string :email, :null => false
      t.string :first_name, :null => false
      t.string :last_name, :null => false, :default => ""
    end
  end

  def self.down
    drop_table :placepop_emails
  end
end
