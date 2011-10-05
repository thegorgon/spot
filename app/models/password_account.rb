class PasswordAccount < ActiveRecord::Base
  FRIENDLY_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  attr_protected :crypted_password
  attr_accessor :password, :current_password
  belongs_to :user
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :password, :presence => true, :if => :password_required?
  validates :password, :length => {:within => (4..25)}, :if => :password_changed?
  validates :login, :presence => true, :format => EMAIL_REGEX, :uniqueness => {:message => "has already been used to register."}
  validate :can_change_password, :if => :password_changed?
  before_save :update_encryption
  before_validation :update_user
  accepts_nested_attributes_for :user
  name_attribute :name

  def self.authenticate(params)
    account = PasswordAccount.find_by_login(params[:login])
    if account && account.valid_password?(params[:password])
      account.user_attributes = params[:user_attributes] if params[:user_attributes]
      account.save
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
  
  def self.register(params, user=nil)
    account = authenticate(params)
    if account && user && account.user && !account.user.new_record? && account.user != user
      account.user.merge_with!(user)
    elsif account && user
      account.user = user
      account.save
    elsif user
      user.attributes = params.delete(:user_attributes)
      user.save if user.changed?
      account = new(params)
      account.user = user
      account.save
    else
      account = create(params)
    end
    account
  end
  
  def email=(value)
    self.login = value
  end
  
  def email
    login
  end
  
  def valid_password?(password)
    self[:crypted_password] == self.class.encrypt(password, password_salt)
  end
  
  def password_changed?
    @password.present?
  end
  
  def password_required?
    self[:crypted_password].blank?
  end
  
  def override_current_password!
    @current_password_check_override = true
  end
  
  def user_synced!
    @user_synced = true
  end
    
  private
  
  def update_encryption
    if password_changed?
      self.password_salt = self.class.generate_salt
      self.crypted_password = self.class.encrypt(@password, password_salt)
    end
    @password = nil
  end
  
  def can_change_password
    errors.add(:current_password, "try again") unless new_record? || valid_password?(@current_password) || @current_password_check_override
  end
  
  def update_user
    unless @user_synced
      self.user ||= User.find_by_email(login)
      self.user ||= User.new
      user.email = login if login.present? && user.email.blank?
      user.first_name = first_name if first_name.present? && user.first_name.blank?
      user.last_name = last_name if last_name.present? && user.last_name.blank?
      user.save if user.changed?
    end
    @user_synced = false
    true
  end
end