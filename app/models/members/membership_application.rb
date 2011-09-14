class MembershipApplication < ActiveRecord::Base  
  belongs_to :user
  belongs_to :city
  serialize :survey
  accepts_nested_attributes_for :user
  after_validation :check_instant_approval
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
    finder = finder.includes(:user)
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
  
  def invite_request
    @invite_request ||= InviteRequest.with_attributes(:email => user.email, :city_id => city_id)
    @invite_request.save if @invite_request.changed?
    @invite_request
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
  
  private
  
  def check_instant_approval
    if invitation && !approved?
      self.approved_at = Time.now
      invitation.claimed!
    end
  end
  
  def user_hasnt_applied
    if MembershipApplication.where(:user_id => user_id).exists?
      errors.add(:base, "Looks like you've already applied. We'll get back to you shortly.")
    end
  end  
end