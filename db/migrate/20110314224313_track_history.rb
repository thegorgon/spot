class TrackHistory < ActiveRecord::Migration
  def self.up
    create_table :activity_items do |t|
      t.integer   :actor_id
      t.integer   :activity_id
      t.string    :activity_type
      t.integer   :item_id
      t.string    :item_type
      t.decimal   :lat, :precision => 11, :scale => 9, :null => false
      t.decimal   :lng, :precision => 12, :scale => 9, :null => false
      t.datetime  :created_at
    end
    add_index :activity_items, [:actor_id, :activity_type]
    
    create_table :user_actions do |t|
      t.integer   :user_id
      t.string    :action_type
      t.integer   :action_id
      t.datetime  :created_at
      t.datetime  :removed_at
    end
    add_index :user_actions, [:user_id, :action_type, :action_id], :unique => true

    add_column :users, :full_name, :string
    add_column :users, :email, :string
  end

  def self.down
    drop_table :activity_items
    drop_table :user_actions

    remove_column :users, :full_name, :email
  end
end
