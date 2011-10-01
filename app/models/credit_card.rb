class CreditCard < ActiveRecord::Base
  CARD_TYPES = ["American Express", "Visa", "Discover", "MasterCard"]
  belongs_to :user
  acts_as_list :scope => :user_id
  validates :token, :presence => true
  validates :user, :presence => true
  validates :card_type, :presence => true, :inclusion => CARD_TYPES
  validates :last_4, :presence => true, :length => {:is => 4}
  validates :expiration_month, :presence => true, :numericality => {:minimum => 1, :maximum => 12}
  validates :expiration_year, :presence => true, :numericality => {:minimum => 2000, :maximum => 3000}
  validate :valid_tr_update
  before_destroy :delete_remote
  
  def self.synced_with(cc)
    record = find_or_initialize_by_token(cc.token)
    record.sync_with(cc)
    record
  end
  
  def sync_with(cc)
    self.token = cc.token
    self.cardholder_name = cc.cardholder_name
    self.card_type = cc.card_type
    self.bin = cc.bin
    self.last_4 = cc.last_4
    self.expiration_month = cc.expiration_month
    self.expiration_year = cc.expiration_year
  end
    
  def obfuscated_number
    if card_type == "American Express"
      "****-******-*#{last_4}"
    elsif card_type
      "****-****-****-#{last_4}"
    end
  end
    
  def short_type
    if card_type == "American Express"
      "amex"
    elsif card_type.present?
      card_type.downcase
    end
  end
  
  def expiration=(date)
    if date.kind_of?(Time)
      self.expiration_month = date.month
      self.expiration_year = date.year
    end
  end
  
  def expiration(separator="/")
    ["%02d" % expiration_month, separator, expiration_year].join
  end
  
  def tr_update_result=(value)
    @tr_update = true
    @tr_update_result = value
    if @tr_update_result.try(:success?)
      sync_with(@tr_update_result.credit_card)
    elsif @tr_update_result
      ccparams = @tr_update_result.params[:credit_card] rescue {}
      ccparams.each do |key, value|
        self[key] = value
      end
    end
  end
  
  def delete_remote
    Braintree::CreditCard.delete(token)
  end
    
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :cardholder_name => cardholder_name,
      :card_type => card_type,
      :last_4 => last_4,
      :expiration_month => expiration_month,
      :expiration_year => expiration_year,
      :obfuscated_number => obfuscated_number
    }
  end
  
  private
  
  def valid_tr_update
    if @tr_update
      if @tr_update_result
        if @tr_update_result.success?
          sync_with(@tr_update_result.credit_card)
        else
          message = @tr_update_result.credit_card_verification.processor_response_code == "3000" ? 
            "There was a problem with the network. Please wait a moment and try again." :
            "There was a problem processing your credit card. Please check your data and try again."
          errors.add(:base, message)
        end
      else
        errors.add(:base, "Something went wrong. Please check your information and try again.")
      end
    end
  end
end