class PreviewSignup < ActiveRecord::Base
  INTERESTS = ["iphone", "business", "city"]
  SEED_RID = 4372
  validates :email, :presence => true, :format => { :with => EMAIL_REGEX }, :uniqueness => {:scope => "interest"}
  validates :interest, :presence => true, :inclusion => INTERESTS
  after_create :credit_referrer
  after_save :send_thank_you, :unless => :emailed?
  
  def self.credit!(id)
    update_counters(id, :referral_count => 1)
  end
  
  def self.signup(params)
    email = params[:email]
    interest = params[:interest]
    if email && preview = find_by_email_and_interest(email, interest)
      preview.attributes = params
      preview.save
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
  
  def rid=(value)
    if value.to_i > SEED_RID
      self.referrer_id = value.to_i - SEED_RID
    end
  end
  
  def rid
    id ? id + SEED_RID : nil
  end
  
  private
  
  def credit_referrer
    self.class.credit!(referrer_id)
  end
  
  def send_thank_you
    if false
      begin 
        TransactionMailer.preview_thanks(self).deliver! 
        update_attribute(:emailed, true)
      rescue
      end
    end
  end
end