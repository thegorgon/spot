class Cities < ActiveRecord::Migration
  def self.up
    create_table :cities do |t|
      t.string    :name, :null => false
      t.string    :fqn, :null => false
      t.string    :slug, :null => false
      t.decimal   :lat, :precision => 11, :scale => 9, :null => false
      t.decimal   :lng, :precision => 12, :scale => 9, :null => false
      t.integer   :radius
      t.integer   :population, :null => false, :default => 0
      t.string    :region, :null => false
      t.string    :region_code, :null => false
      t.string    :country_code, :null => false
      t.integer   :subscriptions_available, :null => false, :default => 0
      t.integer   :subscription_count, :null => false, :default => 0
      t.timestamps
    end
    
    add_index :cities, :slug, :unique => true
  end

  def self.down
    drop_table :cities
  end
end
