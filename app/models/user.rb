class User < ActiveRecord::Base
  attr_protected :admin
  before_validation :reset_persistence_token, :if => :reset_persistence_token?
  before_validation :reset_single_access_token, :if => :reset_single_access_token?
  before_save :reset_perishable_token
  has_many :devices, :dependent => :destroy
  has_many :wishlist_items, :dependent => :delete_all
  has_many :activity_items, :foreign_key => :actor_id, :dependent => :destroy
  has_one :business_account
  has_one :facebook_account
  has_one :password_account
  
  validates :email, :format => EMAIL_REGEX, :uniqueness => true, :if => :email?
  name_attribute :name
  
  def self.adminify!(email)
    if (user = where(:email => email).first)
      user.admin!
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
  
  def wishlist(params)
    item = wishlist_items.active.where(:item_type => params[:item_type], :item_id => params[:item_id]).first
    item || wishlist_items.new(params)
  end
  
  def login!
    self.class.where(:id => id).update_all(["login_count = COALESCE(login_count, 0) + 1, current_login_at = ?, updated_at = ?", Time.now.utc, Time.now.utc])    
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

  def admin!
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
      :name => name
    }
  end
    
  private
  
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