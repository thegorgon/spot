class Membership < ActiveRecord::Base
  FREE_MEMBERSHIP_MAP = {1 => 1, 5 => 12, 10 => 1200}
  belongs_to :user
  belongs_to :city, :counter_cache => "subscription_count"
  belongs_to :payment_method, :polymorphic => true
  validates :city, :presence => true
  validates :payment_method, :presence => true
  validates :starts_at, :presence => true
  attr_writer :tr_result
  
  after_create :convert_application
  after_create :resubscribe_email
  
  has_acquisition_source :count => Proc.new { |obj| obj.acquisition_source.try(:member!, obj) }
    
  scope :active, lambda { where(["starts_at < ? AND expires_at IS NULL OR expires_at > ?", Time.now, Time.now]) }
  scope :expired, lambda { where(["expires_at < ?", Time.now]) }
  scope :expiring, lambda { where(["expires_at BETWEEN ? AND ?", Date.today, Date.tomorrow]) }
  
  def self.deliver_daily_updates
    expiring.find_each { |membership| TransactionMailer.expiring_membership(membership).deliver! rescue nil }
  end
  
  def cancel!
    acquisition_source.try(:unsubscribed!, self)
    
    if payment_method.kind_of?(Subscription)
      payment_method.cancel!
      update_attribute(:expires_at, payment_method.expires_at)
      resubscribe_email
    end
  end
  
  def expired?
    expires_at <= Time.now
  end
  
  def referred!
    if payment_method.respond_to?(:grant_free_months) && payment_method.respond_to?(:cancelled?) && !payment_method.cancelled?
      free_months = FREE_MEMBERSHIP_MAP[referral_count].to_i
      payment_method.grant_free_months(free_months) if free_months > 0
    elsif expires_at.present?
      self.expires_at += 1.month
    end
    save!
  end
  
  def referral_count
    referral_code.signup_count
  end

  def referral_code
    user.invitation_code
  end
  
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :starts_at => starts_at,
      :expires_at => expires_at,
      :payment_method => payment_method
    }
  end
  
  private
    
  def convert_application
    InviteRequest.accounting!(self)
  end  
  
  def resubscribe_email
    user.email_subscriptions.subscription_change!
  end
end