class AddValueToPreviewSignups < ActiveRecord::Migration
  def self.up
    add_column :preview_signups, :value, :string, :null => false, :default => ""
  end

  def self.down
    remove_column :preview_signups, :value
  end
end
