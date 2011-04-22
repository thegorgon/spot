class PasswordAccount < ActiveRecord::Base
  FRIENDLY_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  attr_protected :crypted_password
  attr_accessor :password
  belongs_to :user
  validates :name, :presence => true
  validates :password, :presence => true, :if => :password_required?
  validates :password, :length => {:within => (4..25)}, :if => :password_changed?
  validates :login, :presence => true, :format => EMAIL_REGEX, :uniqueness => true
  before_save :update_encryption
  before_validation :update_user
  name_attribute :name
  
  def self.authenticate(params)
    account = PasswordAccount.find_by_login(params[:login])
    if account && account[:crypted_password] == encrypt(params[:password], account.password_salt) 
      account
    else
      nil
    end
  end
  
  def self.generate_salt
    salt = ""
    1.upto(20) { |i| salt << FRIENDLY_CHARS[rand(FRIENDLY_CHARS.size-1)] }
    salt
  end
  
  def self.encrypt(password, salt)
    digest = [password, salt].join("--")
    20.times { digest = Digest::SHA512.hexdigest(digest) }
    digest
  end
  
  def self.register(params)
    authenticate(params) || create(params)
  end
  
  def password_changed?
    @password.present?
  end
  
  def password_required?
    self[:crypted_password].blank?
  end
  
  private
    
  def update_encryption
    if password_changed?
      self.password_salt = self.class.generate_salt
      self.crypted_password = self.class.encrypt(@password, password_salt)
    end
    @password = nil
  end
  
  def update_user
    self.user ||= User.find_by_email(login)
    self.user ||= User.new
    user.email ||= login
    user.first_name ||= first_name
    user.last_name ||= last_name
    errors.add(:base, "User is invalid") if user.changed? && !user.save
  end
end