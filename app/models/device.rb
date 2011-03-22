class Device < ActiveRecord::Base
  belongs_to :user
  validates :udid, :presence => true
  validates :app_version, :presence => true
  validates :os_id, :presence => true
  validates :platform, :presence => true
  after_validation :create_user, :on => :create

  def self.authenticate(credentials)
    device_credentials = credentials[:device] if credentials
    if device_credentials && device_credentials[:id]
      device = Device.find_or_initialize_by_udid(device_credentials[:id])
      device.attributes = device_credentials.except(:id)
      device.save
    end
    device
  end
  
  def self.user_associate(user, credentials)
    device_credentials = credentials[:device] if credentials
    if device_credentials && device_credentials[:id]
      device = Device.find_or_initialize_by_udid(device_credentials[:id])
      device.bind_to!(user) if device
    end
    device
  end

  def bind_to!(new_user)
    if user && new_user && user != new_user
      self.user = user.merge_with!(new_user)
    elsif user.nil?
      self.user = new_user
    end
    save! if changed?
  end

  private
  
  def create_user
    self.user ||= User.create!
  end
end