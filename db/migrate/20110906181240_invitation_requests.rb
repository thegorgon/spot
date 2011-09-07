class InvitationRequests < ActiveRecord::Migration
  def self.up
    create_table :invite_requests do |t|
      t.string :email, :null => false
      t.integer :city_id
      t.string  :requested_city_name
      t.integer :membership_id
      t.timestamp :invite_sent_at
      t.timestamps
    end
    
    add_index :invite_requests, :email, :unique => true 
  end

  def self.down
    drop_table :invite_requests
  end
end
