class AddDatesToSignups < ActiveRecord::Migration
  def self.up
    add_column :preview_signups, :created_at, :datetime
  end

  def self.down
    remove_column :preview_signups, :created_at
  end
end
