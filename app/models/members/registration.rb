class Registration
  include ActiveModel::Validations
  extend ActiveModel::Callbacks
  attr_accessor :code, :event, :user
  define_model_callbacks :save
  
  after_save :deliver_registration_email
  after_save :count_acquisition
  validate :valid_event
  validate :membership
  validate :user_can_register
  validate :code_available
  validate :user_hasnt_register
  
  def initialize(params={})
    self.event = PromotionEvent.find_by_id(params[:event_id]) if params[:event_id]
    self.code = event.available_codes.first if event
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
  
  def save!
    raise ActiveRecord::RecordInvalid.new(self) unless save
  end
  
  def code
    @code ||= event.available_codes.first
  end
  
  def to_param
    code.to_param
  end
    
  private
  
  def valid_event
    errors.add(:base, "Sorry, we couldn't find that perk.") unless event
  end
  
  def membership
    errors.add(:base, "Please become a member to reserve perks.") unless user.try(:member?)
  end
  
  def user_can_register
    if user && !user.can_register?
      errors.add(:base, "Sorry, you can only reserve #{user.code_slots} perks at a time.")
    end
  end
  
  def user_hasnt_register
    if user && event && existing = user.codes.for_event(event.id).first
      errors.clear
      errors.add(:base, "Oh, looks like you already reserved that perk. Here's your code : #{existing.code}.")
    end
  end  
  
  def code_available
    if event 
      code ||= event.available_codes.first
      if code.nil?
        errors.add(:base, "Sorry, there are no more codes available for this perk. Please try another date.")
      end
    end
  end
  
  def count_acquisition
    user.active_membership.acquisition_source.try(:registration!)
  end
  
  def deliver_registration_email
    BusinessMailer.code_claimed(code).deliver! if code.business.business_account.send_on_code_claim?
    NotifyMailer.msg("#{code.owner.name} at #{code.owner.email} just claimed #{code.event.name} at #{code.event.place.name} on #{code.date} : #{code.code}").deliver!
    TransactionMailer.registration_confirmation(user, code).deliver!
  end
end