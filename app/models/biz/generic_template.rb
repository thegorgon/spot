class GenericTemplate < PromotionTemplate
  validates :value, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :cost, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :description, :presence => true, :length => {:minimum => 10}
  
  nested_attributes({:value => :int, :cost => :int}, {:in => :parameters})
  
  def est_value
    value - cost > 0 ? nil : value - cost
  end
  
  def summary
    summary = "#{count} : "
    if short_summary.present?
      summary << short_summary 
    else
      stripped_description = description.gsub(/<[^\>]+\>/, '')
      summary <<"#{stripped_description.length > 25 ? stripped_description.slice(0, 22) + '...' : stripped_description}"
    end
    
    if value.to_i > 0 || cost.to_i > 0
      summary << " ("
      summary << "value : $#{value}" if value.to_i > 0
      summary << " cost : #{cost.to_i > 0 ? "$#{cost}" : "free"}"
      summary << ")"
    end
    summary
  end

  def event_class
    GenericEvent
  end
end