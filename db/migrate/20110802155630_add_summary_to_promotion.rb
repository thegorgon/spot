class AddSummaryToPromotion < ActiveRecord::Migration
  def self.up
    add_column :promotion_templates, :bulleted, :text
    remove_column :promotion_templates, :cost_cents
  end

  def self.down
    remove_column :promotion_templates, :bulleted
    add_column :promotion_templates, :cost_cents, :integer
  end
end
