class FacebookAccount < ActiveRecord::Base
  belongs_to :user
  validates :facebook_id, :presence => true, :uniqueness => true
  validates :access_token, :presence => true, :uniqueness => true
  validates :email, :format => EMAIL_REGEX
  after_validation :update_user
    
  def self.authenticate(params, user=nil)
    if params && params[:facebook_id] && params[:access_token]
      account = find_or_initialize_by_facebook_id(params[:facebook_id])
      account.access_token = params[:access_token]
      if account.sync!
        if user && account.user && !account.user.new_record? && account.user != user
          account.user.merge_with!(user)
        elsif user
          account.user = user
        end
      else
        nil
      end
    end
  end
  
  def sync!
    if fb_user
      self.name         = fb_user.name
      self.first_name   = fb_user.first_name
      self.last_name    = fb_user.last_name
      self.locale       = fb_user.locale
      self.email        = fb_user.email
      self.gender       = fb_user.gender
      self.save! if changed?
      true
    else
      false
    end
  end
  
  def fb_user
    if @fb_user
      @fb_user
    else
      response = Wrapr::FbGraph::User.find(facebook_id, :access_token => access_token)
      @fb_user = response if response && facebook_id == response.id && response.email.present? && response.email =~ EMAIL_REGEX
    end    
  end

  private
  
  def update_user
    self.user ||= User.find_by_email(email) if email
    self.user ||= User.new
    user.first_name ||= first_name if first_name?
    user.last_name ||= last_name if last_name?
    user.email ||= email if email?
    user.save! if user.changed?
  end
end