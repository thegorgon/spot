class PreviewSignup < ActiveRecord::Base
  SEED_RID = 4372
  CURRENT_TEST = 1
  validates :email, :presence => true, :format => { :with => EMAIL_REGEX }, :uniqueness => true
  before_validation :set_test
  after_create :credit_referrer
  
  def self.credit!(id)
    update_counters(id, :referral_count => 1)
  end
  
  def self.signup(params)
    email = params[:email]
    if email && preview = find_by_email(email)
      preview
    else
      new(params)
    end
  end
  
  def rid=(value)
    if value.to_i > SEED_RID
      self.referrer_id = value.to_i - SEED_RID
    end
  end
  
  def rid
    id ? id + SEED_RID : nil
  end
  
  private
  
  def set_test
    self.test = CURRENT_TEST
  end
  
  def credit_referrer
    self.class.credit!(referrer_id)
  end
end