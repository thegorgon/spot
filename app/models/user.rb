class User < ActiveRecord::Base
  before_validation :reset_persistence_token, :on => :create
  has_many :devices, :dependent => :destroy
  has_many :wishlist_items, :dependent => :destroy
  validates_uniqueness_of :perishable_token, :if => :perishable_token_changed?
  
  def merge_with!(new_user)
    new_items = new_user.wishlist_items.hash_by { |item| "#{item.item_type} #{item.item_id}" }
    current_items = wishlist_items.hash_by { |item| "#{item.item_type} #{item.item_id}" }
    intersecting_keys = new_items.keys & current_items.keys
    new_keys = new_items.keys - current_items.keys
    # Update new keys to point to this user
    WishlistItem.where(:id => new_keys.collect { |key| new_items[key].id }).update_all(:user_id => id) if new_keys.length > 0
    # Delete duplicates
    WishlistItem.where(:id => intersecting_keys.collect { |key| new_items[key].id }).delete_all if intersecting_keys.length > 0
    new_user.destroy
    self
  end
  
  def login!
    self.class.where(:id => id).update_all(["login_count = COALESCE(login_count, 0) + 1, current_login_at = ?, updated_at = ?", Time.now.utc, Time.now.utc])    
  end

  def as_json(*args)
    options = args.extract_options!
    hash = {
      :_type => self.class.to_s,
      :id => id,
      :full_name => full_name
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

end