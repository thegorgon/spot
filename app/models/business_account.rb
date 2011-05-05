class BusinessAccount < ActiveRecord::Base
  DEFAULT_MAX_BUSINESSES = 3
  
  belongs_to :user
  has_many :businesses, :dependent => :destroy
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true, :format => EMAIL_REGEX
  validates :phone, :presence => true
  validates :title, :presence => true
  validates :max_businesses_count, :presence => true, :numericality => { :minimum => 0 }
  before_validation :set_defaults  
  name_attribute :name
  
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
  
  def claim(params)
    biz = businesses.where(:place_id => params[:place_id]).first
    biz || businesses.new(:place_id => params[:place_id])
  end
  
  def can_claim_more_businesses?
    businesses_count < max_businesses_count
  end
  
  def verified?
    !!verified_at
  end
  
  private
  
  def set_defaults
    self[:max_businesses_count] ||= DEFAULT_MAX_BUSINESSES
    self[:first_name] ||= user.first_name
    self[:last_name] ||= user.last_name
    self[:email] ||= user.email
  end
  
end