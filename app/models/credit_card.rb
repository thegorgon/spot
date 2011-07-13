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
end