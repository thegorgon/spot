class AddInterestToPreviews < ActiveRecord::Migration
  def self.up
    add_column :preview_signups, :interest, :string, :null => false
  end

  def self.down
    remove_column :preview_signups, :interest
  end
end
