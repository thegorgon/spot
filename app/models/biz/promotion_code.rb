class PromotionCode < ActiveRecord::Base
  CODE_CHARS = ['A', 'b', 'C', 'd', 'E', 'F', 'G', 'H', 'i', 'J', 'K', 'L', 'M', 'N', 'P', 'q', 'R', 's', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'] + ("1".."9").to_a 
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
  scope :for_event, lambda { |id| where(:event_id => id)}
  scope :for_business, lambda { |id| where(:business_id => id)}
  scope :upcoming, lambda { where("date >= ?", Date.yesterday) }
  scope :in_two_days, lambda { where("date = ?", (Date.today + 2.days)) }
  
  def self.random_code
    (0..3).collect { CODE_CHARS[rand(CODE_CHARS.length)] }.join
  end
  
  def self.deliver_reminders
    self.issued.in_two_days.find_each do |code|
      TransactionMailer.registration_reminder(code.owner, code).deliver
    end
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
      user.touch(:updated_at)
      event.try(:sold!)
    end
  end
  
  def unissue!
    if issued?
      self.class.transaction do
        owner.touch(:updated_at)
        update_attributes!(:owner_id => nil, :issued_at => nil)
        event.try(:unsold!)
      end
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
  
  def set_attributes_from_event
    self.start_time = event.start_time
    self.end_time = event.end_time
    self.date = event.date
    self.business = event.business
  end  
  
  def as_json(*args)
    {
      :_type => "PromotionCode",
      :id => id,
      :event => event.as_json(:api => true),
      :code => code,
      :issued_at => issued_at
    }
  end
  
  private
  
  def assign_code
    self.code ||= self.class.random_code
    assign_code if PromotionCode.where(:business_id => business_id, :code => code, :date => (date - 90.days..date + 90.days)).exists?
  end  
end