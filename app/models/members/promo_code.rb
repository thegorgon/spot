class PromoCode < ActiveRecord::Base
  validates :description, :presence => true
end