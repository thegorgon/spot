class TrackDuplicatePlaces < ActiveRecord::Migration
  def self.up
    create_table :duplicate_places do |t|
      t.integer :place_1_id
      t.integer :place_2_id
      t.decimal :name_distance, :precision => 9, :scale => 2
      t.decimal :address_distance, :precision => 9, :scale => 2
      t.decimal :geo_distance, :precision => 9, :scale => 2
      t.decimal :total_distance, :precision => 9, :scale => 2
      t.integer :status, :limit => 4, :null => false, :default => 0
      t.integer :canonical_id
      t.timestamps
    end
    add_index :duplicate_places, [:place_1_id, :place_2_id], :unique => true
    
    add_column :places, :canonical_id, :integer, :null => false, :default => 0
    add_index :places, :canonical_id    
  end

  def self.down
    remove_column :places, :canonical_id
    drop_table :duplicate_places
  end
end
