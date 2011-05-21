class Business < ActiveRecord::Base
  belongs_to :business_account, :counter_cache => true
  belongs_to :place
  has_many :deal_templates
  has_many :deal_events
  has_many :deal_codes
  validate :account_can_claim, :on => :create
  before_validation :autovalidate, :on => :create
  accepts_nested_attributes_for :place
  
  def self.filter(n)
    finder = self
    finder = finder.where(:verified_at => nil) if n & 1 > 0
    finder = finder.where("verified_at IS NOT NULL") if n & 2 > 0
    finder = finder.order("id DESC")
    finder = finder.includes(:place, :business_account)
    finder
  end
  
  def to_param
    "#{id}-#{place.name.parameterize}"
  end
  
  def status_string
    verified?? "Verified" : "Unverified"
  end
  
  def toggle_verification!
    verified?? unverify! : verify!
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
  
  def deliver_deal_codes_for!(date)
    date = Date.parse(date) if date.kind_of?(String)
    date = Time.at(date).to_date if date.kind_of?(Fixnum)
    if deal_events.on_date(date).count > 0
      BusinessMailer.deal_codes(self, date).deliver!
      true
    else
      false
    end
  end
  
  private
  
  def account_can_claim
    errors.add(:base, "You cannot claim any more businesses. Please contact us to upgrade your account.") unless business_account.can_claim_more_businesses?
  end
  
  def autovalidate
    self.verified_at = Time.now if business_account.verified?
  end
end