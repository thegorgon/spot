class InvitationCode < ActiveRecord::Base
  INITIAL_COUNT = 10
  belongs_to :user
  before_validation :set_code
  before_validation :set_invitation_count
  validates :code, :presence => true, :uniqueness => true
  
  scope :invites_remaining, where("invitation_count < 0 || invitation_count - claimed_count > 0")
  scope :system_codes, where("user_id IS NULL OR user_id <= 0")
  scope :expended, where("invitation_count > 0 && invitation_count >= claimed_count")

  def self.valid_code(code)
    invites_remaining.find_by_code(code)
  end
  
  def self.device_code
    find_or_create_by_code("DEVICE33")
  end
  
  def promo_code
    PromoCode.valid_code(code)
  end
    
  def invites_remaining
    invitation_count < 0 ? -1 : invitation_count - claimed_count
  end
  
  def invites_remaining?
    invites_remaining != 0
  end
  
  def claimed!
    if invites_remaining?
      self.class.increment_counter :claimed_count, id
    end
  end
  
  def signup!
    self.class.increment_counter :signup_count, id
  end
  
  def available?
    invitation_count < 0 || invitation_count - claimed_count > 0
  end
  
  def voucher
    user.try(:first_name) || "Someone"
  end
  
  def as_json(*args)
    { 
      :id => id,
      :voucher => voucher,
      :user => user.as_json(*args),
      :available => available?
    }
  end

  def percentage_full
    if invites_remaining > 0 
      (100 * invites_remaining/invitation_count.to_f).round
    elsif invites_remaining == 0
      invites_remaining
    else
      100
    end
  end
  
  def set_invitation_count
    if user && invitation_count <= 0
      self.invitation_count = user.active_membership ? INITIAL_COUNT : 0 
    end
  end
  
  private
    
  def set_code
    self.code ||= String.token(6)
  end
end