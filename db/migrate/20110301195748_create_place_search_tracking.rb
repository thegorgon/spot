class CreatePlaceSearchTracking < ActiveRecord::Migration
  def self.up
    create_table :place_searches do |t|
      t.string    :query, :null => false
      t.string    :position
      t.decimal   :lat, :precision => 11, :scale => 9
      t.decimal   :lng, :precision => 12, :scale => 9
      t.integer   :result_id
    end
  end

  def self.down
    drop_table :place_searches
  end
end
