class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :place_notes do |t|
      t.integer :user_id, :null => false
      t.integer :place_id, :null => false
      t.text :content, :null => false, :default => ""
      t.integer :status, :null => false, :default => 0
      t.datetime :deleted_at
      t.timestamps
    end
    add_index :place_notes, :user_id
    add_index :place_notes, :place_id
  end

  def self.down
    drop_table :place_notes
  end
end
