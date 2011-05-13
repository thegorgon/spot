class DealEvent < ActiveRecord::Base
  belongs_to :deal_template
  belongs_to :business
  before_validation :set_attributes_from_template
  validate :one_deal_template_event_per_date, :on => :create
  
  def date
    starts_at.to_date
  end
  
  def date=(value)
    year, month, date = value.split('-')
    @date = Time.gm(year, month, date, 0, 0, 0)
  end
    
  def summary
    "#{deal_count} deals per day at #{discount_percentage}% off, #{timeframe}"
  end
  
  def timeframe
    if all_day?
      "all day"
    else
      "#{Time.twelve_hour(start_time, :midnight => true, :noon => true)} to #{Time.twelve_hour(end_time, :midnight => true, :noon => true)}"
    end
  end
  
  def start_time
    starts_at.hour
  end
  
  def end_time
    ends_at.hour
  end
  
  def all_day?
    start_time == 0 && end_time == 0
  end
  
  def remaining_count
    deal_count - sale_count
  end
  
  def remove!
    if sale_count == 0
      destroy
    else
      update_attributes!(:removed_at => Time.now, :deal_count => sale_count)
    end
  end
  
  def removed?
    !!removed_at?
  end
  
  def as_json(*args)
    hash = super(*args)
    hash['color'] = deal_template.try(:color) || '#808080'
    hash['timeframe'] = timeframe
    hash['summary'] = summary
    hash['remaining_count'] = remaining_count
    hash['start_time'] = start_time
    hash['end_time'] = end_time
    hash['date'] = date
    hash
  end
  
  private
  
  def set_attributes_from_template
    if deal_template.present?
      self.deal_count = deal_template.deal_count if deal_count.to_i <= 0
      self.discount_percentage = deal_template.discount_percentage if discount_percentage.to_i <= 0
      self.description ||= deal_template.description
      self.name ||= deal_template.name
      self.estimated_cents_value = deal_template.average_spend * discount_percentage if estimated_cents_value.to_i <= 0
      self.cost_cents = deal_template.cost_cents if cost_cents.to_i <= 0
      self.approved_at = Time.now if deal_template.approved?
      if @date.present?
        self.starts_at ||= @date.at_midnight + deal_template.start_time.hours
        self.ends_at ||= (deal_template.start_time < deal_template.end_time ? @date.at_midnight : @date.at_midnight.tomorrow) + deal_template.end_time.hours
      end
    end
    true
  end
  
  def one_deal_template_event_per_date    
    if business.deal_events.where("DATE(deal_events.starts_at) = ?", date).where(:deal_template_id => deal_template_id).count > 0
      errors.add(:base, "this deal is already active on that date")
    end
  end
end