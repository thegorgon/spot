class Registration
  include ActiveModel::Validations
  attr_accessor :code, :event, :user
  
  validates :event, :presence => true
  validates :user, :presence => true
  validate :user_can_register
  validate :user_hasnt_register
  validate :code_available
  
  def initialize(params={})
    self.event = PromotionEvent.find(params[:event_id]) if params[:event_id]
    self.code = @event.available_codes.first if event
    self.user = User.find(params[:user_id]) if params[:user_id]
  end
  
  def promotion
    @promotion ||= event.template
  end
  
  def place
    @place ||= event.business.place
  end
  
  def save
    if valid?
      code.issue_to!(user)
      true
    else
      false
    end
  end
  
  def to_param
    code.to_param
  end
  
  private
  
  def user_can_register
    unless user.can_register?
      errors.add(:base, "Sorry, you've already registered for the maximum number of events.")
    end
  end
  
  def user_hasnt_register
    if user.codes.for_event(event.id).exists?
      errors.add(:base, "Sorry, you can only register for an event once.")
    end
  end  
  
  def code_available
    code ||= @event.available_codes.first
    if code.nil? 
      errors.add(:base, "Sorry, this event is now fully booked. Please try another date.")
    end
  end
end