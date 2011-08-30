class AcquisitionEvent < ActiveRecord::Base
  belongs_to :email_subscriptions
  belongs_to :acquisition_source
  validates :event_id, :presence => true
  
  CLICK                     = 1
  EMAIL_ACQUIRED            = 2
  APPLIED                   = 3
  SIGNUP                    = 4
  MEMBERSHIP                = 5
  REGISTRATION              = 6
  UNSUBSCRIBED              = 7
  ABOUT_MEMBERSHIP_VIEW     = 8
  APPLICATION_VIEW          = 9
  CITY_MAP_VIEW             = 10
  HOME_PAGE_VIEW            = 11
  MEMBERSHIP_FORM_VIEW      = 12
  
  uniq_constants!
  
  def self.lookup(string)
    const_get(string.gsub(/\s/, "_").upcase)
  end
end