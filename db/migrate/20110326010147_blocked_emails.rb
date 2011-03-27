class BlockedEmails < ActiveRecord::Migration
  def self.up
    create_table :blocked_emails do |t|
      t.string :address, :null => false
      t.string :source, :null => false, :default => "other"
      t.timestamps
    end
    add_index :blocked_emails, :address, :unique => true
    add_column :preview_signups, :emailed, :boolean, :null => false, :default => 0
  end

  def self.down
    drop_table :blocked_emails
    remove :preview_signups, :emailed
  end
end
