class AddInterestToPreviews < ActiveRecord::Migration
  def self.up
    add_column :preview_signups, :interest, :string, :null => false
    remove_index :preview_signups, :email
    add_index :preview_signups, [:interest, :email], :unique => true
  end

  def self.down
    remove_index :preview_signups, [:interest, :email]
    remove_column :preview_signups, :interest
    add_index :preview_signups, :email
  end
end
