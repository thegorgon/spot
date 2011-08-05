class AddSummaryToPromotion < ActiveRecord::Migration
  def self.up
    add_column :promotion_templates, :bulleted, :text
    add_column :promotion_templates, :designed_by_spot, :boolean, :null => false, :default => 0
    
    remove_column :promotion_templates, :cost_cents
  end

  def self.down
    remove_column :promotion_templates, :bulleted
    remove_column :promotion_templates, :designed_by_spot
    add_column :promotion_templates, :cost_cents, :integer
  end
end
