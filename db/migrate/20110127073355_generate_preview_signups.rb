class GeneratePreviewSignups < ActiveRecord::Migration
  def self.up
    create_table :preview_signups do |t|
      t.string :email, :null => false
      t.integer :referral_count, :null => false, :default => 0
      t.integer :test, :null => false, :default => 0
      t.integer :referrer_id
    end
    add_index :preview_signups, :email, :unique => true
  end

  def self.down
    drop_table :preview_signups
  end
end
