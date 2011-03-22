class FacebookAccount < ActiveRecord::Base
  belongs_to :user
  validates :facebook_id, :presence => true, :uniqueness => true
  validates :access_token, :presence => true, :uniqueness => true
  validates :email, :format => EMAIL_REGEX, :if => :email?
  after_validation :update_user
  
  def self.authenticate(params)
    if params && params[:facebook_id] && params[:access_token]
      account = find_or_initialize_by_facebook_id(params[:facebook_id])
      account.access_token = params[:access_token]
      account.sync! ? account : nil
    end
  end
  
  def sync!
    fbuser = Wrapr::FbGraph::User.find(facebook_id, :access_token => access_token)
    if fbuser && facebook_id == fbuser.id
      self.name         = fbuser.name
      self.first_name   = fbuser.first_name
      self.last_name    = fbuser.last_name
      self.locale       = fbuser.locale
      self.email        = fbuser.email
      self.gender       = fbuser.gender
      self.save! if changed?
      true
    else
      false
    end
  end

  private
  
  def update_user
    self.user ||= User.new
    user.email = email if email?
    user.save! if user.changed?
  end
end