class MembershipApplication < ActiveRecord::Base  
  belongs_to :user
  belongs_to :city
  serialize :survey
  accepts_nested_attributes_for :user
  before_validation :set_token
  after_create :deliver_thank_you
  validate :user_hasnt_applied
  validates :token, :presence => true, :uniqueness => true

  def status
    approved?? "approved" : "pending review"
  end

  def approved?
    !!approved_at && Time.now > approved_at
  end
  
  def approve!
    unless approved?
      update_attribute(:approved_at, Time.now)
      deliver_approved
    end
  end

  def survey=(value)
    self[:survey] = value
  end

  def survey
    self[:survey] ||= {}
  end
  
  def deliver_thank_you
    TransactionMailer.application_thanks(self).deliver!
  end
  
  def deliver_approved
    TransactionMailer.application_approved(self).deliver!
  end
  
  def to_param
    token
  end
  
  private
  
  def user_hasnt_applied
    if MembershipApplication.where(:user_id => user_id).exists?
      errors.add(:base, "Looks like you've already applied. We'll get back to you shortly.")
    end
  end
  
  def set_token
    self.token = String.token(5)
  end
end