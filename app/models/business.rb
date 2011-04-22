class Business < ActiveRecord::Base
  belongs_to :business_account, :counter_cache => true
  belongs_to :place
  validate :account_can_claim
  
  def to_param
    "#{id}-#{place.name.parameterize}"
  end
  
  private
  
  def account_can_claim
    errors.add(:base, "You cannot claim any more businesses. Please contact us to upgrade your account.") unless business_account.can_claim_more_businesses?
  end
end