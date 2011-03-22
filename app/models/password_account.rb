class PasswordAccount < ActiveRecord::Base
  FRIENDLY_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  attr_protected :crypted_password
  attr_accessor :password
  belongs_to :user
  validates :password, :presence => true
  validates :login, :presence => true, :format => EMAIL_REGEX, :uniqueness => true
  after_validation :update_encryption
  after_validation :update_user
  
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
  
  private
    
  def update_encryption
    if @password.present?
      self.password_salt = self.class.generate_salt
      self.crypted_password = self.class.encrypt(@password, password_salt)
    end
    @password = nil
  end
  
  def update_user
    self.user ||= User.new
    user.email = login
    user.save! if user.changed?
  end
end