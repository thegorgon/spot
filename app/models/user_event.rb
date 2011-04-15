class UserEvent < ActiveRecord::Base
  validates :user_id, :presence => true
  validates :event_id, :presence => true
  validates :locale, :presence => true
end