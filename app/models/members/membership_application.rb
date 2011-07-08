class MembershipApplication < ActiveRecord::Base  
  belongs_to :user
  belongs_to :city
  serialize :survey
  accepts_nested_attributes_for :user
  before_validation :set_token
  after_create :deliver_thank_you
  validates :token, :presence => true, :uniqueness => true

  def status
    approved?? "approved" : "pending review"
  end

  def approved?
    Time.now - created_at >= 1.day
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
  
  def to_param
    token
  end
  
  private
  
  def set_token
    self.token = String.token(5)
  end
end