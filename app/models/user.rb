class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validate_password_field = false
    c.validate_email_field = false
    c.validate_login_field = false
  end
  before_validation :reset_persistence_token, :on => :create
  has_many :devices, :dependent => :destroy
  has_many :wishlist_items, :dependent => :destroy
  
  
  def as_json(*args)
    options = args.extract_options!
    hash = {
      :_type => self.class.to_s,
      :id => id
    }
  end  
end