class MembershipApplication < ActiveRecord::Base  
  belongs_to :user
  belongs_to :city
  serialize :survey
  accepts_nested_attributes_for :user
  after_create :deliver_thank_you, :unless => :approved?
  after_validation :check_instant_approval
  after_save :send_approval_email
  validate :user_hasnt_applied, :on => :create

  has_acquisition_source :count => :applied

  scope :unapproved, where(:approved_at => nil)
  scope :approved, where("approved_at IS NOT NULL")
  scope :ready_for_approval, where(["approved_at IS NULL AND created_at < ?", Time.now - 24.hours])

  def self.filter(n)
    finder = self
    finder = finder.unapproved if n & 1 > 0
    finder = finder.approved if n & 2 > 0
    finder = finder.ready_for_approval if n & 4 > 0
    finder
  end
  
  def self.approve_pending
    self.ready_for_approval.find_each do |app|
      app.approve!
    end
  end

  def toggle_approval!
    approved?? unapprove! : approve!
  end
  
  def status
    approved?? "approved" : "pending review"
  end

  def approved?
    !!approved_at && Time.now > approved_at
  end
  
  def approve!
    unless approved?
      self.approved_at = Time.now
      save
    end
  end

  def unapprove!
    if approved?
      update_attribute(:approved_at, nil)
    end
  end

  def converted!
    invitation.try(:signup!)
  end
  
  def invitation
    invitation_code && InvitationCode.valid_code(invitation_code)
  end
  
  def promo_code
    if invitation_code && pc = PromoCode.valid_code(invitation_code)
      pc.code
    else
      nil
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
  
  private
  
  def check_instant_approval
    if invitation && !approved?
      self.approved_at = Time.now
      invitation.claimed!
    end
  end

  def send_approval_email
    deliver_approved if approved? && approved_at_was.nil?
  end
  
  def user_hasnt_applied
    if MembershipApplication.where(:user_id => user_id).exists?
      errors.add(:base, "Looks like you've already applied. We'll get back to you shortly.")
    end
  end  
end