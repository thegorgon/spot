class AddBlitzCountToRequests < ActiveRecord::Migration
  def self.up
    add_column :invite_requests, :blitz_count, :integer, :null => false, :default => 0
    add_column :invite_requests, :last_blitz_at, :datetime
  end

  def self.down
    remove_column :invite_requests, :last_blitz_at
    remove_column :invite_requests, :blitz_count
  end
end
