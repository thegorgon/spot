class ShortUrls < ActiveRecord::Migration
  def self.up
    create_table :short_urls do |t|
      t.string :url
      t.integer :visits, :null => false, :default => 0
      t.datetime :last_visit_at
      t.timestamps
    end
    add_index :short_urls, :url, :unique => true
  end

  def self.down
    drop_table :short_urls
  end
end
