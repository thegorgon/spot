class PromoCode < ActiveRecord::Base
  validates :name, :presence => true
  validates :code, :presence => true, :length => {:minimum => 5}
  validates :description, :presence => true
  validates :duration, :presence => true, :numericality => {:greater_than_or_equal_to => -1}
  validates :user_count, :presence => true, :numericality => {:greater_than_or_equal_to => -1}
  validates :use_count, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  
  scope :available, where("user_count < 0 OR user_count - use_count > 0")
  
  def self.valid_code(code)
    available.find_by_code(code)
  end
  
  def self.device_code
    nil
  end
  
  def used!
    self.class.increment_counter(:use_count, id)
    reload
  end
  
  def expiration_if_started_now
    duration >= 0 ? Time.now + duration.months : nil
  end
  
  def require_credit_card
    !acts_as_payment
  end

  def require_credit_card=(value)
    self.acts_as_payment = value.respond_to?(:to_i) ? value.to_i == 0 : !value
  end
  
  def as_json(*args)
    { 
      :_type => self.class.to_s,
      :id => id,
      :name => name,
      :description => description,
      :duration => duration,
      :available => available?,      
      :acts_as_payment => acts_as_payment
    }
  end
    
  def available?
    user_count < 0 || user_count - use_count > 0
  end
end