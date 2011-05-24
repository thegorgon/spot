class BusinessAccount < ActiveRecord::Base
  NOTIFICATION_FLAGS = ["weekly_digest"]
  DEFAULT_MAX_BUSINESSES = 3
  
  belongs_to :user
  has_many :businesses, :dependent => :destroy
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true, :format => EMAIL_REGEX
  validates :phone, :presence => true
  validates :title, :presence => true
  validates :max_businesses_count, :presence => true, :numericality => { :minimum => 0 }
  
  before_validation :set_defaults, :on => :create
  after_create :deliver_welcome_message 
  
  name_attribute :name
  setting_flags NOTIFICATION_FLAGS, :attr => "requested_notifications", 
                                    :field => "notification_flags", 
                                    :method_prefix => "send_"

  def self.register(params)
    user = User.find_by_id(params[:user_id]) if params[:user_id]
    unless user
      password_account = PasswordAccount.register(:login => params[:email], :password => params[:password], :name => params[:name])
      user = password_account.user
    end
    user.business_account = BusinessAccount.new do |ba|
      ba.name = params[:name]
      ba.email = params[:email]
      ba.phone = params[:phone]
      ba.title = params[:title]
    end
  end
  
  def self.deliver_weekly_notifications
    with_setting("weekly_digest").find_each do |account|
      BusinessMailer.weekly_digest(account).deliver!
    end
  end
  
  def email_with_name
    "#{name} <#{email}>"
  end
  
  def claim(params)
    biz = businesses.where(:place_id => params[:place_id]).first
    biz || businesses.new(:place_id => params[:place_id])
  end
  
  def can_claim_more_businesses?
    businesses_count < max_businesses_count
  end
  
  def toggle_verification!
    verified?? unverify! : verify!
  end
  
  def verify!
    update_attribute(:verified_at, Time.now)
    businesses.map { |b| b.verify! }
  end

  def unverify!
    update_attribute(:verified_at, nil)
    update_attribute(:verified_at, Time.now)
    businesses.map { |b| b.unverify! }
  end
  
  def verified?
    !!verified_at
  end
  
  private
  
  def deliver_welcome_message
    BusinessMailer.welcome(self).deliver!
  end
  
  def set_defaults
    self[:max_businesses_count] = DEFAULT_MAX_BUSINESSES if self.max_businesses_count.to_i <= 0
    self[:first_name] ||= user.try(:first_name)
    self[:last_name] ||= user.try(:last_name)
    self[:email] ||= user.try(:email)
    NOTIFICATION_FLAGS.each do |flag| 
      send("send_#{flag}=", true)
    end
  end
  
end