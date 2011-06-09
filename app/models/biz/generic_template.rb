class GenericTemplate < PromotionTemplate
  validates :value, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :cost, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :description, :presence => true, :length => {:minimum => 10}
  
  nested_attributes({:value => :int, :cost => :int}, {:in => :parameters})
  
  def est_value
    value - cost > 0 ? nil : value - cost
  end
  
  def summary
    "#{count} : #{description.length > 25 ? description.slice(0, 22) + '...' : description}"
  end

  def event_class
    GenericEvent
  end
end