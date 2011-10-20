class InviteRequest < ActiveRecord::Base
  CODES = ["SUSHI17", "CABERNET12", "CAVIAR29", "OYSTER42", "CANOLI77", "PASTRY98", "CHEF18", "WINE56", "DINE18", "FORK52"]
  MAX_BLITZ = 10
  belongs_to :city
  belongs_to :membership
  validates :email, :presence => true, :format => EMAIL_REGEX
  before_validation :handle_duplicate_email
  after_save :mark_sent!
  after_save :ensure_email_subscription
  after_create :send_coming_soon
  
  attr_accessor :invite_code
  
  scope :unsent_invites, where(:invite_sent_at => nil)
  scope :sent_invites, where("invite_sent_at IS NOT NULL")
  scope :city_available, select("invite_requests.*").joins(:city).where("cities.subscriptions_available > cities.subscription_count")
  scope :ready_for_sending, lambda { city_available.where(["invite_requests.invite_sent_at IS NULL AND invite_requests.created_at < ?", Time.now - 1.hours]) }
  scope :need_blitzing, lambda { 
    select("invite_requests.*").includes(:city).city_available.where(
      ["invite_requests.invite_sent_at < ? AND membership_id IS NULL AND blitz_count < ? AND (last_blitz_at IS NULL OR last_blitz_at < ?)", 
              Time.now - 1.day, MAX_BLITZ, Time.now - 3.days]
    ).joins("INNER JOIN email_subscriptions ON email_subscriptions.email = invite_requests.email").where(EmailSubscriptions.without_setting_sql("newsletter_emails")) 
  }
  
  name_attribute :name
  
  def self.filter(n)
    finder = self
    finder = finder.unsent_invites if n & 1 > 0
    finder = finder.sent_invites if n & 2 > 0
    finder = finder.ready_for_sending if n & 4 > 0
    finder = finder.order("id DESC").includes(:city, :membership)
    finder
  end
  
  def self.random_code
    @random_code ||= InvitationCode.find_or_create_by_code(CODES.random)
  end
  
  def self.blitz_experiences(city)
    @experiences ||= {}
    if @experiences[city.id].nil?
      @experiences[city.id] = []
      templates = city.upcoming_events.group(:template_id)
      3.times do |i|
        @experiences[city.id] << templates.delete_at(rand(templates.length))
      end
    end
    @experiences[city.id]
  end
  
  def self.send_blitzes
    need_blitzing.find_each do |request|
      BlitzMailer.email(request, :invite_code => random_code.code, :experiences => blitz_experiences(request.city)).deliver!
    end
    
    sent = need_blitzing.update_all("blitz_count = COALESCE(blitz_count, 0) + 1, last_blitz_at = '#{Time.now.to_s(:db)}'")

    NotifyMailer.msg("We Just Sent Blitz Emails #{sent} Times.").deliver! if sent > 0
  end
  
  def self.with_attributes(params={})
    params ||= {}
    request = where(:email => params[:email]).first
    request ||= new
    request.attributes = params
    request
  end
  
  def self.accounting!(membership)
    transaction do 
      record = find_or_initialize_by_email(membership.user.email)
      record.invite_sent_at ||= Time.now
      record.update_attributes!( :first_name => membership.user.first_name, 
                                 :last_name => membership.user.last_name, 
                                 :city_id => membership.city_id, 
                                 :membership_id => membership.id )
    end
  end
  
  def self.autosend
    n = 0
    InviteRequest.ready_for_sending.find_each do |r|
      n = n + 1
      r.send_invite!
    end
    NotifyMailer.msg("We just sent out #{n} automatically requested invitations.").deliver! if n > 0
  end

  def city_name
    if city_id.to_i > 0 && city
      city.name
    else
      requested_city_name
    end
  end
  
  def invite_sent?
    !!invite_sent_at
  end
  
  def send_invite!
    TransactionMailer.invitation(self).deliver!
    mark_sent! unless invite_sent?
  end
  
  def mark_sent!
    touch(:invite_sent_at)
  end
  
  def invite
    self.class.random_code if invite_sent?
  end
  
  private
  
  def handle_duplicate_email
    if existing = self.class.where(:email => email).where("id <> ?", id).first
      existing.attributes = attributes.slice("city_id", "requested_city_name", "first_name", "last_name")
      existing.save
      self.id = existing.id
      reload
    end
  end
    
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