class DiscountEvent < PromotionEvent
  validates :discount_percentage, :presence => true, :inclusion => PromotionTemplate::DISCOUNTS
  validates :average_spend, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

  nested_attributes({:discount_percentage => :int, :average_spend => :int}, {:in => :parameters})
  
  def summary
    "#{count.pluralize('customer')} at #{discount_percentage}% off, #{timeframe}"
  end

  def savings(party_size)
    ((average_spend * party_size * discount_percentage)/100.0) - dollar_cost
  end

  def set_attributes_from_template
    super
    self.discount_percentage = template.discount_percentage if discount_percentage.to_i <= 0
    self.average_spend = template.average_spend if average_spend.to_i <= 0
  end

  def code_class
    DiscountCode
  end
end