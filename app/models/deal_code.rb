class DealCode < ActiveRecord::Base
  CODE_CHARS = ['A', 'b', 'C', 'd', 'E', 'F', 'G', 'H', 'i', 'J', 'K', 'L', 'M', 'N', 'P', 'q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'] + ("1".."9").to_a 
  belongs_to :owner, :class_name => "User"
  belongs_to :business
    
  validates :business, :presence => true
  validates :code, :presence => true
  validates :discount_percentage, :presence => true, :inclusion => DealTemplate::DISCOUNTS
  validates :date, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  
  before_validation :assign_code, :on => :create
  
  scope :available, where(:locked_at => nil, :issued_at => nil)
  scope :issued, where("issued_at IS NOT NULL")
  
  def self.random_code
    (0..3).collect { CODE_CHARS[rand(CODE_CHARS.length)] }.join
  end
  
  def deal_event=(value)
    self[:deal_event_id] = value.id
    self.discount_percentage = value.discount_percentage
    self.start_time = value.start_time
    self.end_time = value.end_time
    self.date = value.date
    self.business = value.business
    @deal_event = value
  end
  
  def deal_event
    @deal_event ||= DealEvent.find(deal_event_id) if deal_event_id
  end
  
  def lock!
    update_attribute(:locked_at, Time.now)
  end

  def release!
    update_attribute(:locked_at, nil)
  end
  
  def redeem!
    update_attribute(:redeemed_at, Time.now) if issued?
  end
    
  def issue_to!(user)
    self.class.transaction do
      update_attributes!(:owner_id => user.id, :issued_at => Time.now)
      deal_event.try(:sold!)
    end
  end
  
  def issued?
    !!issued_at
  end
  
  def redeemed?
    !!redeemed_at
  end
  
  def status_string
    if issued? && redeemed?
      "redeemed"
    elsif issued?
      "issued"
    else
      "unissued"
    end
  end
  
  private
  
  def assign_code
    self.code ||= self.class.random_code
    assign_code if DealCode.where(:business_id => business_id, :code => code, :date => (date - 90.days..date + 90.days)).exists?
  end
    
end