class WishlistItem < ActiveRecord::Base
  ITEM_TYPES = ["Place"]
  belongs_to :user
  belongs_to :item, :polymorphic => true
  validates :user_id, :presence => true, :numericality => true
  validates :item_type, :presence => true, :inclusion => ITEM_TYPES
  validates :item_id, :presence => true, :numericality => true, :uniqueness => { :scope => [:user_id, :item_type] }
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
end