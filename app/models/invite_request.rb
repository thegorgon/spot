class InviteRequest < ActiveRecord::Base
  CODES = ["SUSHI17", "CABERNET12", "CAVIAR29", "OYSTER42", "CANOLI77", "PASTRY98", "CHEF18", "WINE56", "DINE18", "FORK52"]
  belongs_to :city
  belongs_to :membership
  validates :email, :presence => true, :format => EMAIL_REGEX, :uniqueness => true
  after_save :ensure_email_subscription
  after_create :send_coming_soon
  
  scope :unsent_invites, where(:invite_sent_at => nil)
  scope :sent_invites, where("invite_sent_at IS NOT NULL")
  scope :ready_for_sending, joins(:city).where(["invite_requests.invite_sent_at IS NULL AND invite_requests.created_at < ? AND cities.subscriptions_available > cities.subscription_count", Time.now - 1.hours])
  
  def self.filter(n)
    finder = self
    finder = finder.unsent_invites if n & 1 > 0
    finder = finder.sent_invites if n & 2 > 0
    finder = finder.ready_for_sending if n & 4 > 0
    finder = finder.order("id DESC").includes(:city, :membership)
    finder
  end
  
  def self.blitz!
  end
  
  def self.accounting!(membership)
    where(:email => membership.user.email).update_all(:membership_id => membership.id)
  end
  
  def self.autosend
    count = 0
    InviteRequest.ready_for_sending.find_each do |request|
      count += 1
      request.send_invite!
    end
    TransactionMailer.notify_invites_sent(count).deliver!
  end

  def city_name
    if city_id > 0 && city
      city.name
    else
      requested_city_name
    end
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