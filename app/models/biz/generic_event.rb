class GenericEvent < PromotionEvent
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

  def savings(party_size)
    est_value ? est_value * party_size : nil
  end

  def set_attributes_from_template
    super
    self.value = template.value if value.to_i <= 0
    self.cost = template.cost if cost.to_i <= 0
  end

  def code_class
    GenericCode
  end
end