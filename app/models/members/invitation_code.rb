class InvitationCode < ActiveRecord::Base
  belongs_to :user
  before_validation :set_code
  validates :code, :presence => true, :uniqueness => true
  
  def self.valid_code(code)
    invitation = find_by_code(code)
    invitation && invitation.invites_remaining? ? invitation : nil
  end
  
  def invites_remaining
    invitation_count < 0 ? -1 : claimed_count - invitation_count
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
  
  private
  
  def set_code
    self.code ||= String.token(6)
  end
end