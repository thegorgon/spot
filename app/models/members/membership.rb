class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :city
  belongs_to :payment_method, :polymorphic => true
  validates :city, :presence => true
  validates :payment_method, :presence => true
  validates :starts_at, :presence => true
  attr_writer :tr_result
  
  after_create :convert_application
  
  scope :active, lambda { where(["starts_at < ? AND expires_at IS NULL OR expires_at > ?", Time.now, Time.now]) }
  scope :expired, lambda { where(["expires_at < ?", Time.now]) }
  
  def cancel!
    if payment_method.kind_of?(Subscription)
      payment_method.cancel!
      update_attribute(:expires_at, payment_method.expires_at)
    end
  end
  
  def expired?
    expires_at <= Time.now
  end
  
  private
  
  def convert_application
    user.membership_application.converted!
  end
end