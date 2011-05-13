class Business < ActiveRecord::Base
  belongs_to :business_account, :counter_cache => true
  belongs_to :place
  has_many :deal_templates
  has_many :deal_events
  validate :account_can_claim, :on => :create
  before_validation :autovalidate, :on => :create
  accepts_nested_attributes_for :place
  
  def to_param
    "#{id}-#{place.name.parameterize}"
  end
  
  def status_string
    verified?? "Verified" : "Unverified"
  end
  
  def verify!
    update_attribute(:verified_at, Time.now)
  end

  def unverify!
    update_attribute(:verified_at, nil)
  end
  
  def verified?
    !!verified_at
  end
  
  private
  
  def account_can_claim
    errors.add(:base, "You cannot claim any more businesses. Please contact us to upgrade your account.") unless business_account.can_claim_more_businesses?
  end
  
  def autovalidate
    self.verified_at = Time.now if business_account.verified?
  end
end