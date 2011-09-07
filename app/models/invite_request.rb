class InviteRequest < ActiveRecord::Base
  CODES = ["SUSHI17", "CABERNET12", "CAVIAR29", "OYSTER42", "CANOLI77", "PASTRY98", "CHEF18", "WINE56", "DINE18", "FORK52"]
  belongs_to :city
  belongs_to :membership
  validates :email, :presence => true, :format => EMAIL_REGEX, :uniqueness => true
  after_save :ensure_email_subscription
  after_create :send_coming_soon
  
  scope :unsent_invites, where(:invite_sent_at => nil)
  scope :sent_invites, where("invite_sent_at IS NOT NULL")
  scope :ready_for_sending, where(["invite_sent_at IS NULL AND created_at < ?", Time.now - 24.hours])
  
  def self.filter(n)
    finder = self
    finder = finder.unsent_invites if n & 1 > 0
    finder = finder.sent_invites if n & 2 > 0
    finder = finder.ready_for_sending if n & 4 > 0
    finder = finder.includes(:city, :membership)
    finder
  end
  
  def self.accounting!(membership)
    where(:email => membership.user.email).update_all(:membership_id => membership.id)
  end

  def city_name
    city.try(:name) || requested_city_name
  end
  
  def invite_sent?
    !!invite_sent_at
  end
  
  def send_invite!
    invite_code = InvitationCode.find_or_create_by_code(CODES.random)
    TransactionMailer.invitation(self, invite_code).deliver!
    update_attribute(:invite_sent_at, Time.now)
  end
  
  private
  
  def send_coming_soon
    if city_name.present? && (city.nil? || !city.subscriptions_available?)
      TransactionMailer.invite_coming_soon(self).deliver!
    end
  end
  
  def ensure_email_subscription
    EmailSubscriptions.ensure( :email => email, 
                               :city_id => city_id, 
                               :other_city => requested_city_name)
  end
end