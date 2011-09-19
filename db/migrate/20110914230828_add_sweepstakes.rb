class AddSweepstakes < ActiveRecord::Migration
  def self.up
    create_table :sweepstakes do |t|
      t.integer :place_id, :null => false
      t.integer :entries_count, :null => false, :default => 0
      t.string :name, :null => false
      t.string :short_summary, :null => false
      t.string :grand_prize, :null => false
      t.integer :prize_value, :null => false
      t.text :description, :null => false
      t.datetime :starts_on, :null => false
      t.datetime :ends_on, :null => false
      t.integer :winning_entry_id
      t.timestamps
    end
    
    create_table :sweepstake_entries do |t|
      t.integer :sweepstake_id, :null => false
      t.integer :invite_request_id, :null => false
      t.integer :submissions, :null => false, :default => 1
      t.string  :referral_code, :null => false
      t.string  :referred_by_id
      t.timestamps
    end
    add_index :sweepstake_entries, [:sweepstake_id, :invite_request_id], :unique => true, :name => "index_sweepstake_entries_on_sweepstake_and_request"
    add_index :sweepstake_entries, :referral_code, :unique => true
  
    add_column :invite_requests, :first_name, :string
    add_column :invite_requests, :last_name, :string
  end

  def self.down
    drop_table :sweepstakes
    drop_table :sweepstake_entries
    remove_column :invite_requests, :first_name, :last_name
  end
end
