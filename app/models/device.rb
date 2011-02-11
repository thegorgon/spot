class Device < ActiveRecord::Base
  SUPPORTED_PLATFORMS = ['iphone']
  belongs_to :user
  validates :udid, :presence => true
  validates :app_version, :presence => true
  validates :os_id, :presence => true
  validates :platform, :presence => true, :inclusion => {:in => SUPPORTED_PLATFORMS}
  after_validation :create_user, :on => :create

  private
  
  def create_user
    self.user ||= User.create!
  end
end