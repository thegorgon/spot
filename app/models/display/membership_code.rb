class MembershipCode
  include ActiveModel::Validations

  attr_accessor :invite, :promo, :code
  validate :code, :presence => true
  validate :valid_invite
  validate :valid_promo
  
  def initialize(params={})
    self.invite = InvitationCode.new(params[:invite]) if params[:invite] && params[:invite_code]
    self.promo = PromoCode.new(params[:promo]) if params[:promo] && params[:promo_code]
    self.code = params[:code] if params[:code]
  end
  
  def self.new_code
    mc = MembershipCode.new
    mc.invite = InvitationCode.new
    mc.promo = PromoCode.new
    mc
  end
  
  def self.by_code
    if @codes.nil?
      @codes = {}
      InvitationCode.system_codes.all.each do |invite|
        @codes[invite.code] ||= MembershipCode.new
        @codes[invite.code].invite = invite
        @codes[invite.code].code = invite.code
      end
      PromoCode.all.each do |promo|
        @codes[promo.code] ||= MembershipCode.new
        @codes[promo.code].promo = promo
        @codes[promo.code].code = promo.code
      end
    end
    @codes
  end
  
  def self.find_by_code(code)
    mc = new
    mc.invite = InvitationCode.find_by_code(code)
    mc.promo = PromoCode.find_by_code(code)
    mc
  end
  
  def destroy
    invite.try(:destroy)
    promo.try(:destroy)
  end
  
  def invite_code
    invite.present?
  end
  
  def promo_code
    promo.present?
  end
  
  def code=(value)
    @code = value
    invite.code = value if invite
    promo.code = value if promo
  end
  
  def to_param
    code
  end
  
  def to_key
    ["membership_code","#{(code || "new").downcase}"]
  end
  
  def save
    if valid?
      (invite.nil? || invite.save) && (promo.nil? || promo.save)
    end
  end
  
  private
  
  def valid_invite
    if invite && !invite.valid?
      errors.add(:invite, "is not valid")
    end
  end
  
  def valid_promo
    if promo && !promo.valid?
      errors.add(:promo, "is not valid")
    end
  end
end