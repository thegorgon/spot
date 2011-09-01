class OptimizeExperiences < ActiveRecord::Migration
  def self.up
    add_column  :promotion_events, "lat", :decimal, :precision => 11, :scale => 9
    add_column  :promotion_events, "lng", :decimal, :precision => 12, :scale => 9
    add_column  :promotion_events, "place_id", :integer
    add_column  :promotion_events, "short_summary", :string
    add_column  :promotion_templates, "place_id", :integer
    rename_column :promotion_templates, "bulleted", "short_summary"
    
    execute("UPDATE promotion_events SET short_summary = (SELECT short_summary FROM promotion_templates WHERE promotion_templates.id = promotion_events.template_id);")
    execute("UPDATE promotion_events SET place_id = (SELECT place_id FROM businesses WHERE businesses.id = promotion_events.business_id);")
    execute("UPDATE promotion_events SET lat = (SELECT lat FROM places WHERE places.id = promotion_events.place_id);")
    execute("UPDATE promotion_events SET lng = (SELECT lng FROM places WHERE places.id = promotion_events.place_id);")
    execute("UPDATE promotion_templates SET place_id = (SELECT place_id FROM businesses WHERE businesses.id = promotion_templates.business_id);")
    
    change_column :promotion_events, "lat", :decimal, :precision => 11, :scale => 9, :null => false
    change_column :promotion_events, "lng",  :decimal, :precision => 12, :scale => 9, :null => false
    change_column :promotion_events, "place_id", :integer, :null => false
    change_column :promotion_templates, "place_id", :integer, :null => false
  end

  def self.down
    remove_column  :promotion_events, "lat"
    remove_column  :promotion_events, "lng"
    remove_column  :promotion_events, "place_id"
    remove_column  :promotion_templates, "place_id"
    remove_column  :promotion_events, "short_summary"
    rename_column :promotion_templates, "short_summary", "bulleted"
  end
end
