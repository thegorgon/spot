class AddOfflineProcessingColumns < ActiveRecord::Migration
  def self.up
    add_column :places, :image_processing, :boolean, :null => false, :default => false
    add_column :places, :delta,            :boolean, :null => false, :default => true
    remove_column :places, :status
  end

  def self.down
    remove_column :places, :image_processing
    remove_column :places, :delta
    add_column    :places, :status, :integer, :null => false, :default => 0
  end
end
