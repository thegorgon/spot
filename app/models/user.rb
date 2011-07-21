class User < ActiveRecord::Base
  NOTIFICATION_FLAGS = ["deal_emails"]

  attr_protected :admin
  before_validation :reset_persistence_token, :if => :reset_persistence_token?
  before_validation :reset_single_access_token, :if => :reset_single_access_token?
  before_save :reset_perishable_token
  after_save :send_deals_welcome_email
  has_many :devices, :dependent => :destroy
  has_many :wishlist_items, :dependent => :delete_all
  has_many :activity_items, :foreign_key => :actor_id, :dependent => :destroy
  has_many :credit_cards
  has_many :subscriptions
  has_many :memberships
  has_many :codes, :foreign_key => :owner_id, :class_name => "PromotionCode"
  has_many :notes, :class_name => "PlaceNote"
  has_one :membership_application
  has_one :business_account
  has_one :facebook_account
  has_one :password_account
  belongs_to :city
  
  validates :email, :format => EMAIL_REGEX, :uniqueness => true, :if => :email?
  name_attribute :name
  setting_flags NOTIFICATION_FLAGS, :attr => "requested_notifications", 
                                    :field => "notification_flags", 
                                    :method_prefix => "notify_"
  
  def self.adminify!(email)
    if (user = where(:email => email).first)
      user.adminify!
      true
    else
      false
    end
  end

  def self.find_using_perishable_token(token, age=1.day) 
    if token.present?
      finder = self
      finder = finder.where(["updated_at > ?", age.to_i.seconds.ago]) if age.to_i > 0
      finder = finder.where(:perishable_token => token)
      finder.first
    end
  end
    
  def self.register(params)
    account = FacebookAccount.authenticate(params)
    account ||= PasswordAccount.register(params)
    user = account.try(:user)
    if user
      user.city_id = params[:city_id]
    end
    user
  end
  
  def email_with_name
    "#{name} <#{email}>"
  end
  
  def invitation_code
    unless @invitation_code
      @invitation_code ||= InvitationCode.find_or_initialize_by_user_id(id)
      @invitation_code.save if @invitation_code.new_record?
    end
    @invitation_code
  end
  
  def merge_with!(new_user)
    new_items = new_user.wishlist_items.hash_by { |item| "#{item.item_type} #{item.item_id}" }
    current_items = wishlist_items.hash_by { |item| "#{item.item_type} #{item.item_id}" }
    intersecting_keys = new_items.keys & current_items.keys
    new_keys = new_items.keys - current_items.keys
    # Update new keys to point to this user
    WishlistItem.where(:id => new_keys.collect { |key| new_items[key].id }).update_all(:user_id => id) if new_keys.length > 0
    # Delete duplicates
    WishlistItem.where(:id => intersecting_keys.collect { |key| new_items[key].id }).delete_all if intersecting_keys.length > 0
    Device.where(:user_id => new_user.id).update_all(:user_id => id)
    PasswordAccount.where(:user_id => new_user.id).update_all(:user_id => id)
    FacebookAccount.where(:user_id => new_user.id).update_all(:user_id => id)
    new_user.destroy
    self
  end
  
  def active_membership
    @active_membership ||= memberships.active.first
  end
  
  def expired_memberships
    @expired_memberships ||= memberships.expired.all
  end
    
  def can_register?
    member? && codes.count < code_slots
  end
  
  def code_slots
    3
  end
  
  def member?
    !!active_membership
  end
  
  def wishlist(params)
    item = wishlist_items.active.where(:item_type => params[:item_type], :item_id => params[:item_id]).first
    item || wishlist_items.new(params)
  end
  
  def login!
    self.class.where(:id => id).update_all(["login_count = COALESCE(login_count, 0) + 1, current_login_at = ?, updated_at = ?", Time.now.utc, Time.now.utc])    
  end
  
  def names
    [first_name, last_name]
  end
    
  def nickname
    if @nickname.blank?
      if first_name.present? && last_name.present?
        @nickname = [first_name, last_name.to_s.first].compact.join(" ")
        @nickname << "."
      else
        @nickname = [first_name, last_name].compact.join
      end
      @nickname.downcase!
    end
    @nickname
  end

  def adminify!
    update_attribute(:admin, true)
  end
      
  def reset_perishable_token!
    reset_perishable_token
    save!
  end
  
  def reset_persistence_token!
    reset_persistence_token
    save!
  end

  def as_json(*args)
    options = args.extract_options!
    hash = {
      :_type => self.class.to_s,
      :id => id,
      :first_name => first_name,
      :last_name => last_name,
      :email => email,
      :name => name,
      :requested_notifications => requested_notifications
    }
  end
    
  private
  
  def send_deals_welcome_email
    if (email.present? && !was_notify_deal_emails? && notify_deal_emails?)
      DealMailer.welcome(self).deliver!
    end
  end
  
  def reset_persistence_token
    self.persistence_token = Nonce.hex_token
  end

  def reset_single_access_token
    self.single_access_token = Nonce.friendly_token
  end

  def reset_perishable_token
    self.perishable_token = Nonce.friendly_token
  end
  
  def reset_single_access_token?
    single_access_token.blank?
  end
  
  def reset_persistence_token?
    persistence_token.blank?
  end
end