class Registration
  include ActiveModel::Validations
  extend ActiveModel::Callbacks
  attr_accessor :code, :event, :user
  define_model_callbacks :save
  
  after_save :deliver_registration_email
  after_save :count_acquisition
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
    @place ||= event.place
  end
  
  def save
    _run_save_callbacks do
      if valid?
        code.issue_to!(user)
        true
      else
        false
      end
    end
  end
  
  def to_param
    code.to_param
  end
  
  private
  
  def user_can_register
    if user && !user.can_register?
      errors.add(:base, "Sorry, you've already registered for the maximum number of events.")
    end
  end
  
  def user_hasnt_register
    if user && user.codes.for_event(event.id).exists?
      errors.add(:base, "Sorry, you can only register for an event once.")
    end
  end  
  
  def code_available
    code ||= @event.available_codes.first
    if code.nil? 
      errors.add(:base, "Sorry, this event is now fully booked. Please try another date.")
    end
  end
  
  def count_acquisition
    user.active_membership.acquisition_source.try(:registration!)
  end
  
  def deliver_registration_email
    TransactionMailer.registration_confirmation(user, code).deliver!
  end
end