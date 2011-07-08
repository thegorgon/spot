class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :payment_method
  
  scope :active, lambda { where(["starts_at < ? AND expires_at IS NULL OR expires_at > ?", Time.now, Time.now]) }
end