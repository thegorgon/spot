class BlockedEmail < ActiveRecord::Base
  validates :address, :presence => true, :format => EMAIL_REGEX
  
  def self.block!(email)
    record = find_or_initialize_by_address(email)
    record.save!
  end
  
  def self.blocked?( email )
    !(email =~ EMAIL_REGEX) || self.count(:conditions => {:address => email.downcase}) > 0
  end
end
