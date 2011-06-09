class DiscountCode < PromotionCode
  validates :discount_percentage, :presence => true, :inclusion => PromotionTemplate::DISCOUNTS
  
  nested_attributes({:discount_percentage => :int}, {:in => :parameters})
  
  def set_attributes_from_event
    super
    self.discount_percentage = event.discount_percentage
  end
end