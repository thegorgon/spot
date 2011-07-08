class PromotionEvent < ActiveRecord::Base
  belongs_to :template, :class_name => "PromotionTemplate"
  belongs_to :business
  has_many :codes, :class_name => "PromotionCode", :foreign_key => "event_id", :dependent => :delete_all
  before_validation :set_attributes_from_template, :if => Proc.new { |e| e.template.present? }
  after_create :generate_codes
  validate :one_template_event_per_date, :on => :create, :if => Proc.new { |e| e.template.present? }
  
  scope :on_date, lambda { |date| where(:date => date.to_date)}
  scope :upcoming, lambda { where(["date >= ?", Date.today]).order("date ASC") }
  scope :this_week, lambda { where(:date => (Date.today..(Time.now + 7.days).to_date)) }
  scope :this_month, lambda { where(:date => (Date.today..(Time.now + 1.month).to_date)) }
  scope :approved, joins(:template).where("promotion_templates.status" => PromotionTemplate::APPROVED_STATUS)
  scope :within, lambda { |radius, options| 
    joins(:business => :place).where(["? <= ?", Place.distance_sql(options[:origin]), radius])
  }
  
  def self.summary(timeframe=nil)
    timeframe ||= (Date.today..(Time.now + 2.weeks).to_date)
    strings = []
    timeframe.each do |date|
      strings << "\n#{date.strftime('%A, %B %d, %Y')} : \n"
      approved.on_date(date).each do |event|
        strings << "#{event.business.place.name}, #{event.timeframe} : "
        strings << "  #{event.description}"
        event.codes.each do |code|
          strings << "         CODE : #{code.code}"
        end
        strings << "\n"
      end
    end
    puts strings.join("\n")
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
      
  def all_day?
    start_time == 0 && end_time == 0
  end
  
  def remaining_count
    count - sale_count
  end
  
  def sold!
    self.class.increment_counter :sale_count, id
  end
  
  def remove!
    if sale_count == 0
      destroy
    else
      codes.available.delete_all
      update_attributes!( :removed_at => Time.now, 
                          :count => codes.count, 
                          :sale_count => codes.count)
    end
  end
  
  def removed?
    !!removed_at?
  end
  
  def available_codes
    codes.available
  end
  
  def color
    template.try(:color) || '#808080'
  end
  
  def as_json(*args)
    hash = super(*args)
    hash['color'] = color
    hash['timeframe'] = timeframe
    hash['summary'] = summary
    hash['remaining_count'] = remaining_count
    hash
  end
  
  def code_class
    PromotionCode
  end
  
  private
  
  def generate_codes
    count.times do |i|
      code_class.create!(:event => self)
    end
  end
  
  def set_attributes_from_template
    self.count = template.count if count.to_i <= 0
    self.description ||= template.description
    self.name ||= template.name
    self.cost_cents = template.cost_cents if cost_cents.to_i <= 0
    self.approved_at = Time.now if template.approved?
    self.start_time ||= template.start_time
    self.end_time ||= template.end_time
  end
  
  def one_template_event_per_date    
    if business.promotion_events.where(:template_id => template_id, :date => date).count > 0
      errors.add(:base, "this promotion is already active on that date")
    end
  end

end