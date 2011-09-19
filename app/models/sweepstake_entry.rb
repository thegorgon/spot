class SweepstakeEntry < ActiveRecord::Base
  belongs_to :sweepstake, :counter_cache => :entries_count
  belongs_to :invite_request
  belongs_to :referred_by, :class_name => "SweepstakeEntry"
  
  validates :sweepstake, :presence => true
  validates :invite_request, :presence => true
  validates :invite_request_id, :uniqueness => { :scope => :sweepstake_id }
  validates :referral_code, :presence => true, :uniqueness => { :scope => :sweepstake_id }
  
  validate :in_valid_date_range
  
  before_validation :set_referral_code
  before_validation :set_min_submissions
  after_create :credit_referrer, :if => :referred?
  
  delegate :email, :city_id, :first_name, :last_name, :to => :invite_request
  
  def referred_by_code=(value)
    if value
      self[:referred_by_id] = self.class.find_by_referral_code(value).try(:id)
    else
      self[:referred_by_id] = nil
    end
  end
  
  def referred?
    referred_by_id.to_i > 0
  end
  
  def as_json(*args)
    {
      :email => email,
      :submissions => submissions,
      :first_name => first_name,
      :last_name => last_name,
      :referral_code => referral_code
    }
  end
      
  private
  
  def in_valid_date_range
    if sweepstake.pending?
      errors.add(:base, "Submissions will open #{sweepstake.starts_on.strftime("%B %d, %Y")} at 1:00 a.m. Pacific Time.")
    elsif sweepstake.closed?
      errors.add(:base, "Sorry, submissions are closed.")
    end
  end
  
  def credit_referrer
    self.class.increment_counter(:submissions, referred_by_id)
  end
  
  def set_min_submissions
    self.submissions = [submissions, 1].max
  end
  
  def set_referral_code
    self.referral_code ||= String.token(6)
  end
end