class PromotionCode < ActiveRecord::Base
  CODE_CHARS = ['A', 'b', 'C', 'd', 'E', 'F', 'G', 'H', 'i', 'J', 'K', 'L', 'M', 'N', 'P', 'q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'] + ("1".."9").to_a 
  belongs_to :owner, :class_name => "User"
  belongs_to :business
  belongs_to :event, :class_name => "PromotionEvent"
  before_validation :set_attributes_from_event, :if => Proc.new { |c| c.event.present? }
  
  validates :business, :presence => true
  validates :code, :presence => true
  validates :date, :presence => true
  validates :start_time, :presence => true
  validates :end_time, :presence => true
  
  before_validation :assign_code, :on => :create
  
  scope :redeemed, where("redeemed_at IS NOT NULL")
  scope :available, where(:locked_at => nil, :issued_at => nil)
  scope :issued, where("issued_at IS NOT NULL")
  
  def self.random_code
    (0..3).collect { CODE_CHARS[rand(CODE_CHARS.length)] }.join
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
      event.try(:sold!)
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
    assign_code if PromotionCode.where(:business_id => business_id, :code => code, :date => (date - 90.days..date + 90.days)).exists?
  end
  
  def set_attributes_from_event
    self.start_time = event.start_time
    self.end_time = event.end_time
    self.date = event.date
    self.business = event.business
  end  
end