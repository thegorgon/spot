class GenericCode < PromotionCode
  validates :description, :presence => true, :length => {:minimum => 10}
  nested_attributes({:description => :string}, {:in => :parameters})

  def set_attributes_from_event
    super
    self.description = event.description
  end
end