class PromotionTemplate < ActiveRecord::Base
  has_many :events, :class_name => "PromotionEvent", :foreign_key => "template_id", :dependent => :destroy
  belongs_to :business
  belongs_to :place
  attr_protected :approved_at
  
  after_save :update_events
  
  DISCOUNTS = [25, 30, 40, 50]
  APPROVED_STATUS = 2
  REJECTED_STATUS = 1
  PENDING_STATUS  = 0
  REMOVED_STATUS  = -1
  STATUSES = [APPROVED_STATUS, REJECTED_STATUS, PENDING_STATUS, REMOVED_STATUS]
  
  validates :name, :presence => true
  validates :count, :presence => true, :numericality => {:greater_than => 0, :less_than => 101}
  validates :status, :inclusion => STATUSES
  validates :business, :presence => true
  validates :place, :presence => true
  acts_as_list :scope => 'business_id = #{business_id} AND status >= 0'

  scope :active, where("status >= 0")
  scope :rejected, where(:status => REJECTED_STATUS)
  scope :approved, where(:status => APPROVED_STATUS)
  scope :pending, where(:status => PENDING_STATUS)

  before_validation :set_place
  after_validation :determine_status_change

  def self.filter(n)
    finder = self
    finder = finder.pending  if n & (1 << 0) > 0
    finder = finder.approved if n & (1 << 1) > 0
    finder = finder.rejected if n & (1 << 2) > 0
    finder = finder.active
    finder = finder.order("id DESC")
    finder = finder.includes({:business => :business_account, :place => nil})
    finder
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
      
  def color
    Color.hex_series(position.to_i).first
  end
  
  def timeframe(use_all_day=true)
    if use_all_day && all_day?
      "all day"
    else
      "#{Time.twelve_hour(start_time, :midnight => true, :noon => true)} to #{Time.twelve_hour(end_time, :midnight => true, :noon => true)}"
    end
  end

  def all_day?
    start_time == 6 && end_time == 6
  end

  def as_json(*args)
    hash = super
    hash['summary'] = summary
    hash['color'] = color
    hash['timeframe'] = timeframe
    hash
  end
  
  def event_class
    PromotionEvent
  end
  
  def generate_event(params)
    event = event_class.new(params)
    event.template = self
    event
  end
  
  # ============
  # = STATUSES =
  # ============
    
  def status_string
    case status
    when APPROVED_STATUS
      "approved"
    when REJECTED_STATUS
      "rejected"
    when REMOVED_STATUS
      "removed"
    when PENDING_STATUS
      "pending"
    else
      "error"
    end
  end
  
  [:approved, :rejected, :pending, :removed].each do |name|
    define_method "#{name}?" do
      status == self.class.const_get("#{name}_status".upcase)
    end
    
    define_method "#{name}!" do
      update_attribute(:status, self.class.const_get("#{name}_status".upcase))
    end
    
    define_method "was_#{name}?" do
      status_was == self.class.const_get("#{name}_status".upcase)
    end
  end
  
  private
  
  def update_events
    events.all.each do |event|
      event.set_attributes_from_template
      event.save
    end
  end
  
  def set_place
    self.place ||= business.place
  end
  
  def determine_status_change
    if status_changed?
      if was_rejected? && approved?
        # We're about to approve a rejected promotion
        self.rejection_reasoning = nil
        BusinessMailer.promotion_approved(self).deliver!
      elsif was_approved? && rejected?
        # We're about to reject an approved promotion
        errors.add(:base, "Cannot reject a previously approved promotion.")
      elsif was_pending? && approved?
        # We're about to approve a pending promotion
        BusinessMailer.promotion_approved(self).deliver!
      elsif was_pending? && rejected?
        # We're about to approve a pending promotion
        BusinessMailer.promotion_rejected(self).deliver!
      end
    end
  end
end