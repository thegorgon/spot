class PromotionEvent < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  belongs_to :template, :class_name => "PromotionTemplate"
  belongs_to :business
  belongs_to :place
  has_many :codes, :class_name => "PromotionCode", :foreign_key => "event_id", :dependent => :delete_all
  before_validation :set_attributes_from_template, :if => Proc.new { |e| e.template.present? }
  after_create :generate_codes
  
  after_save :update_codes
  
  validate :one_template_event_per_date, :on => :create, :if => Proc.new { |e| e.template.present? }
  validates :name, :presence => true
  validates :description, :presence => true
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
  
  scope :on_date, lambda { |date| where(:date => date.to_date)}
  scope :upcoming, lambda { where(["date >= ?", Date.today]).order("date ASC") }
  scope :this_week, lambda { where(:date => (Date.today..(Time.now + 7.days).to_date)) }
  scope :this_month, lambda { where(:date => (Date.today..(Time.now + 1.month).to_date)) }
  scope :approved, joins(:template).where("promotion_templates.status" => PromotionTemplate::APPROVED_STATUS)

  acts_as_mappable
  
  def timeframe(use_all_day=true)
    if use_all_day && all_day?
      "all day"
    else
      timeframe_array.join ' to '
    end
  end

  def timeframe_array
    [Time.twelve_hour(start_time, :midnight => true, :noon => true), Time.twelve_hour(end_time, :midnight => true, :noon => true)]
  end

  def all_day?
    start_time == 6 && end_time == 6
  end
  
  def remaining_count
    count - sale_count
  end
  
  def available?
    remaining_count > 0
  end
  
  def sold!
    self.class.increment_counter :sale_count, id
    reload
  end

  def unsold!
    self.class.decrement_counter :sale_count, id
    reload
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
    options = args.extract_options!
    if options[:api]
      {
        :_type => self.class.to_s,
        :place => place.as_json(:skip_thumbnail => true),
        :image_url_640x400 => place.image.url(:i640x400),
        :image_url_234x168 => place.image.url(:i234x168),
        :image_url => place.image.url,
        :url => place_event_url(place, self.template, :host => HOSTS[Rails.env]),
        :date => date,
        :name => name,
        :description => description,
        :short_summary => short_summary,
        :start_time => start_time,
        :end_time => end_time,
        :remaining_count => remaining_count
      }
    else
      hash = super(*args)
      hash['color'] = color
      hash['timeframe'] = timeframe
      hash['summary'] = summary
      hash['remaining_count'] = remaining_count
      hash
    end
  end
  
  def code_class
    PromotionCode
  end
  
  def set_attributes_from_template
    self.count = template.count if count.to_i <= 0
    self.description = template.description
    self.short_summary = template.short_summary
    self.name = template.name
    self.approved_at = Time.now if template.approved?
    self.start_time = template.start_time
    self.business = template.business
    self.place = template.business.place
    self.lat = template.business.place.lat
    self.lng = template.business.place.lng
    self.end_time = template.end_time
  end
  
  private
  
  def update_codes
    codes.all.each do |code|
      code.set_attributes_from_event
      code.save
    end
  end
  
  def generate_codes
    count.times do |i|
      code_class.create!(:event => self)
    end
  end
    
  def one_template_event_per_date    
    if business.promotion_events.where(:template_id => template_id, :date => date).count > 0
      errors.add(:base, "this promotion is already active on that date")
    end
  end

end