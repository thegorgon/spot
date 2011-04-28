class PreviewSignup < ActiveRecord::Base
  SEED_RID = 4372
  CURRENT_TESTS = [*2..4]
  FORMATS = {2 => "gif"}
  validates :email, :presence => true, :format => { :with => EMAIL_REGEX }, :uniqueness => true
  before_validation :set_test, :on => :create
  after_create :credit_referrer
  after_save :send_thank_you, :unless => :emailed?
  
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
  
  def self.find_by_rid(rid)
    if rid.to_i > SEED_RID
      find_by_id(rid.to_i - SEED_RID)
    end
  end
  
  def image_format
    FORMATS[test] || "jpg"
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
    self.test = CURRENT_TESTS[rand(CURRENT_TESTS.length)]
  end
  
  def credit_referrer
    self.class.credit!(referrer_id)
  end
  
  def send_thank_you
    unless emailed? || BlockedEmail.blocked?(self.email)
      begin 
        TransactionMailer.preview_thanks(self).deliver! 
        update_attribute(:emailed, true)
      rescue AWS::SES::ResponseError => e
      end
    end
  end
end