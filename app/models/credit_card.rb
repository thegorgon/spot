class CreditCard < ActiveRecord::Base
  CARD_TYPES = ["American Express", "Visa", "Discover", "MasterCard"]
  belongs_to :user
  acts_as_list :scope => :user_id
  validates :token, :presence => true
  validates :user, :presence => true
  validates :card_type, :presence => true, :inclusion => CARD_TYPES
  validates :last_4, :presence => true, :length => {:is => 4}
  validates :expiration_month, :presence => true, :numericality => {:minimum => 1, :maximum => 12}
  validates :expiration_year, :presence => true, :numericality => {:minimum => 2000, :maximum => 3000}
end