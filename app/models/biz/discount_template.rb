class DiscountTemplate < PromotionTemplate
  validates :discount_percentage, :inclusion => DISCOUNTS
  validates :average_spend, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  
  nested_attributes({:discount_percentage => :int, :average_spend => :int}, {:in => :parameters})

  def self.discounts
    unless @discounts
      @discounts = {}
      DISCOUNTS.each do |d|
        @discounts["#{d}%"] = d
      end
    end
    @discounts
  end
    
  def est_value
    average_spend.to_i > 0 ? average_spend.to_i * discount_percentage.to_i/100.0 : "N/A"
  end
  
  def summary
    "#{count.pluralize('customers')} per day at #{discount_percentage}% off, #{timeframe}"
  end
  
  def event_class
    DiscountEvent
  end
end