class BlockedEmail < ActiveRecord::Base
  def self.block!(email, source)
    record = find_or_initialize_by_address(email)
    record.source = source
    record.save!
  end
  
  def self.blocked?( email )
    !(email =~ EMAIL_REGEX) || self.count(:conditions => {:address => email.downcase}) > 0
  end
end
