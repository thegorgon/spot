class ApiChanges < ActiveRecord::Migration
  def self.up
    remove_column :places, :clean_address
    remove_column :places, :clean_name
    rename_column :places, :full_name, :name
    rename_column :places, :full_address, :address
    
    add_column :places, :twitter, :string
    add_column :places, :website, :string
    add_column :places, :note_count, :integer, :null => false, :default => 0
    
    execute("UPDATE places SET note_count = (SELECT COUNT(id) FROM place_notes WHERE place_id = places.id)")

    add_column :users, :wishlist_count, :integer, :null => false, :default => 0

    execute("UPDATE users SET wishlist_count = (SELECT COUNT(id) FROM wishlist_items WHERE user_id = users.id)")
  end

  def self.down
    add_column :places, :clean_address, :string
    add_column :places, :clean_name, :string
    
    rename_column :places, :name, :full_name
    rename_column :places, :address, :full_address
    
    remove_column :places, :twitter, :string
    remove_column :places, :website, :string
    remove_column :places, :note_count, :integer, :null => false, :default => 0
    
    remove_column :users, :wishlist_count, :integer, :null => false, :default => 0
  end
end
