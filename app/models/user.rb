class User < ActiveRecord::Base
  attr_protected :admin
  before_validation :reset_persistence_token, :if => :reset_persistence_token?
  before_validation :reset_single_access_token, :if => :reset_single_access_token?
  before_save :reset_perishable_token
  after_save :save_associations
  after_destroy :cleanup
  
  has_many :devices, :dependent => :destroy
  has_many :wishlist_items, :dependent => :delete_all
  has_many :activity_items, :foreign_key => :actor_id, :dependent => :destroy
  has_many :credit_cards, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_many :codes, :foreign_key => :owner_id, :class_name => "PromotionCode"
  has_many :notes, :class_name => "PlaceNote", :dependent => :delete_all
  has_many :actions, :class_name => "ActivityItem", :foreign_key => "actor_id"
  has_one :business_account, :dependent => :destroy
  has_one :facebook_account, :dependent => :destroy
  has_one :password_account, :dependent => :destroy
  belongs_to :city
  
  validates :email, :format => EMAIL_REGEX, :uniqueness => { :message => "has already been used to register." }, :if => :email?
  has_acquisition_source :count => :signup
  name_attribute :name
  attr_accessor :email_source

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
    
  def self.register(params, user=nil)
    account = FacebookAccount.authenticate(params, user)
    account ||= PasswordAccount.register(params, user)
    user = account.try(:user)
    if user
      user.city_id = params[:city_id]
    end
    user
  end
  
  def wishlist
    if @wishlist.nil?
      @wishlist = wishlist_items.active.includes(:item)
      WishlistItem.prepare_for_nesting(@wishlist)
      @wishlist
    end
    @wishlist
  end
  
  def other_city=(value)
    self[:other_city] = value
    self.city_id = nil if value.present?
  end
  
  def email_with_name
    if name.present?
      "#{name} <#{email}>"
    else
      email
    end
  end
  
  def invite_request
    @invite_request ||= InviteRequest.with_attributes(attributes.slice("email", "first_name", "last_name", "city_id").symbolize_keys!)
  end
  
  def invite_request!
    invite_request.save if invite_request.changed?
    invite_request
  end
  
  def invitation_code
    if @invitation_code.nil?
      @invitation_code ||= InvitationCode.find_or_initialize_by_user_id(id)
      @invitation_code.set_invitation_count
      @invitation_code.save if @invitation_code.changed?
    end
    @invitation_code
  end
  
  def merge_with!(new_user)
    # Move over all records
    [WishlistItem, Device, PlaceNote, PasswordAccount, FacebookAccount, Subscription, CreditCard, Membership].each do |klass|
      klass.where(:user_id => new_user.id).update_all(:user_id => id)
    end
    ActivityItem.where(:actor_id => new_user.id).update_all(:actor_id => id)
    PromotionCode.where(:owner_id => new_user.id).update_all(:owner_id => id)
    # Hash wishlist by item
    wishlist = wishlist_items.all.group_by { |wi| "#{wi.item_type} #{wi.item_id}" }
    ids_to_delete = []
    wishlist.each do |key, array|
      # By item take any wishlist actions that are older than the most recent and mark them deleted
      wishlist[key].sort! { |x1, x2| x2.created_at <=> x1.created_at }
      ids_to_delete += wishlist[key].slice(1, wishlist[key].length)
    end
    WishlistItem.where(:id => ids_to_delete).map { |wi| wi.destroy }
    # This way, any older actions will be considered deleted and the newest action will prevail.
    update_attributes!(:wishlist_count => wishlist_items.active.count, :login_count => login_count + new_user.login_count)
    new_user.destroy
    self
  end
  
  def active_membership(force=false)
    if @active_membership.nil? && (force || !@_fetched_active_membership)
      @active_membership = memberships.active.first
      @_fetched_active_membership = true
    end
    @active_membership
  end
  
  def expired_memberships
    @expired_memberships ||= memberships.expired.all
  end
    
  def can_register?
    member? && codes.upcoming.count < code_slots
  end
  
  def code_slots
    3
  end
  
  def has_account?
    password_account.present? || facebook_account.present?
  end
  
  def ready_for_membership?
    has_account? && email.present? && first_name.present? && last_name.present? && city.present?
  end
  
  def member?
    active_membership
  end
  
  def add_to_wishlist(params)
    item = wishlist_items.active.where(:item_type => params[:item_type], :item_id => params[:item_id]).first
    item || wishlist_items.new(params)
  end
  
  def login!
    self.class.where(:id => id).update_all(["login_count = COALESCE(login_count, 0) + 1, current_login_at = ?, updated_at = ?", Time.now.utc, Time.now.utc])    
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

  def requested_notifications
    email_subscriptions.try(:subscriptions) || []
  end
  
  def requested_notifications=(value)
    if email.present?
      email_subscriptions.subscriptions = value
      email_subscriptions.save
    else
      # Maybe email will be set later, stash it for on save
      @requested_notifications = value
    end
  end
  
  def email_subscriptions
    @email_subscriptions ||= 
      EmailSubscriptions.ensure( :email => email_was || email, 
                                 :first_name => first_name, 
                                 :last_name => last_name, 
                                 :city_id => city_id,
                                 :source => email_source || 'website',
                                 :user_id => id ) if email
  end

  def as_json(*args)
    options = args.extract_options!
    hash = {
      :_type => self.class.to_s,
      :id => id,
      :first_name => first_name,
      :last_name => last_name,
      :name => name,
      :created_at => created_at,
      :updated_at => updated_at
    }
    if options[:current_viewer]
      hash.merge!(
        :membership => active_membership,
        :codes => codes.upcoming.all,
        :code_slots => code_slots,
        :wishlist_count => wishlist_count,
        :city_id => city_id,
        :other_city => other_city,
        :email => email,
        :has_website_account => has_account?,
        :requested_notifications => requested_notifications
      )
    end
    hash
  end
    
  private
  
  def cleanup
    codes.update_all(:owner_id => nil)
    invitation_code.try(:destroy)
    invite_request.try(:destroy)
    email_subscriptions.try(:destroy)
  end
  
  def save_associations
    if password_account
      password_account.email = email
      password_account.first_name = first_name
      password_account.last_name = last_name
      password_account.user_synced!
      password_account.save if password_account.changed?
    end
    if email.present?
      @email_subscriptions = EmailSubscriptions.change(email_was, {
        :email => email,
        :first_name => first_name,
        :last_name => last_name,
        :other_city => other_city,
        :city_id => city_id,
        :source => email_source
      })
      # If requested notifications was set, but email wasn't now we can sync them.
      @email_subscriptions.subscriptions = @requested_notifications if @requested_notifications
      invite_request!
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