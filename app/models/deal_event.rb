class DealEvent < ActiveRecord::Base
  belongs_to :deal_template
  belongs_to :business
  has_many :deal_codes, :dependent => :delete_all
  before_validation :set_attributes_from_template
  after_create :generate_deal_codes
  validates :discount_percentage, :presence => true, :inclusion => DealTemplate::DISCOUNTS
  validate :one_deal_template_event_per_date, :on => :create
  
  scope :on_date, lambda { |date| where(:date => date.to_date)}
      
  def summary
    "#{deal_count.pluralize('deal')} at #{discount_percentage}% off, #{timeframe}"
  end
  
  def timeframe(use_all_day=true)
    if use_all_day && all_day?
      "all day"
    else
      "#{Time.twelve_hour(start_time, :midnight => true, :noon => true)} to #{Time.twelve_hour(end_time, :midnight => true, :noon => true)}"
    end
  end
  
  def dollar_cost
    cost_cents.to_i/100.0
  end
  
  def savings(party_size)
    ((average_spend * party_size * discount_percentage)/100.0) - dollar_cost
  end
    
  def all_day?
    start_time == 0 && end_time == 0
  end
  
  def remaining_count
    deal_count - sale_count
  end
  
  def sold!
    self.class.increment_counter :sale_count, id
  end
  
  def remove!
    if sale_count == 0
      destroy
    else
      deal_codes.available.delete_all
      update_attributes!( :removed_at => Time.now, 
                          :deal_count => deal_codes.count, 
                          :sale_count => deal_codes.count)
    end
  end
  
  def removed?
    !!removed_at?
  end
  
  def available_codes
    deal_codes.available
  end
  
  def color
    deal_template.try(:color) || '#808080'
  end
  
  def as_json(*args)
    hash = super(*args)
    hash['color'] = color
    hash['timeframe'] = timeframe
    hash['summary'] = summary
    hash['remaining_count'] = remaining_count
    hash
  end
  
  private
  
  def generate_deal_codes
    deal_count.times do |i|
      DealCode.create!(:deal_event => self)
    end
  end
  
  def set_attributes_from_template
    if deal_template.present?
      self.deal_count = deal_template.deal_count if deal_count.to_i <= 0
      self.discount_percentage = deal_template.discount_percentage if discount_percentage.to_i <= 0
      self.description ||= deal_template.description
      self.name ||= deal_template.name
      self.average_spend = deal_template.average_spend if average_spend <= 0
      self.cost_cents = deal_template.cost_cents if cost_cents.to_i <= 0
      self.approved_at = Time.now if deal_template.approved?
      self.start_time ||= deal_template.start_time
      self.end_time ||= deal_template.end_time
    end
    true
  end
  
  def one_deal_template_event_per_date    
    if business.deal_events.where(:deal_template_id => deal_template_id, :date => date).count > 0
      errors.add(:base, "this deal is already active on that date")
    end
  end
end