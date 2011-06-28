class Business < ActiveRecord::Base
  belongs_to :business_account, :counter_cache => true
  belongs_to :place
  has_many :promotion_templates
  has_many :promotion_events
  has_many :promotion_codes
  validate :account_can_claim, :on => :create
  before_validation :autoverify, :on => :create
  accepts_nested_attributes_for :place
  
  def self.filter(n)
    finder = self
    finder = finder.where(:verified_at => nil) if n & 1 > 0
    finder = finder.where("verified_at IS NOT NULL") if n & 2 > 0
    finder = finder.order("id DESC")
    finder = finder.includes(:place, :business_account)
    finder
  end
  
  def self.deliver_daily_codes
    joins(:promotion_events).where(["promotion_events.date = ?", Date.today]).find_each do |biz|
      biz.deliver_promotion_codes_for!(Date.today)
    end
  end
  
  def name
    place.name
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def status_string
    verified?? "Verified" : "Unverified"
  end
  
  def toggle_verification!
    verified?? unverify! : verify!
  end
  
  def was_verified?
    verified_at_was.nil?
  end
  
  def verify!(email=true)
    BusinessMailer.verified(self).deliver! if email && !verified?
    update_attribute(:verified_at, Time.now)
  end

  def unverify!
    update_attribute(:verified_at, nil)
  end
  
  def verified?
    !!verified_at
  end
  
  def has_outstanding_promotions?
    promotion_codes.where("date >= #{Date.today.to_s(:db)}").count > 0
  end
  
  def new_promotion_template(params)
    klass = params.delete(:type).classify.constantize
    tpl = klass.new(params)
    tpl.business = self
    tpl
  end

  def new_promotion_event(params)
    template = PromotionTemplate.find(params[:template_id])
    event = template.generate_event(params)
    event.business = self
    event
  end
  
  def deliver_promotion_codes_for!(date)
    date = Date.parse(date) if date.kind_of?(String)
    date = Time.at(date).to_date if date.kind_of?(Fixnum)
    if promotion_events.on_date(date).count > 0
      BusinessMailer.promotion_codes(self, date).deliver!
      true
    else
      false
    end
  end
  
  private
    
  def account_can_claim
    errors.add(:base, "You cannot claim any more businesses. Please contact us to upgrade your account.") unless business_account.can_claim_more_businesses?
    errors.add(:base, "This business has already been claimed. Please contact us to resolve.") if Business.where(:place_id => place_id).exists?
  end
  
  def autoverify
    self.verified_at = Time.now if business_account.verified?
  end  
end