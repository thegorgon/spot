class CreateAppsDb < ActiveRecord::Migration
  def self.up
    create_table :mobile_apps do |t|
      t.string :name, :null => false
      t.string :location, :null => false
      t.string :store_id, :null => false
      t.string :store, :null => false
      t.boolean :live, :null => false, :default => 0
    end
    add_index :mobile_apps, [:store, :location], :unique => true
    
    add_column :users, :location, :string
  end

  def self.down
    drop_table :mobile_apps
    remove_column :users, :location
  end
end
