class Transaction < ActiveRecord::Base
  TXN_TYPES = ["sale", "credit", "subscription"]
  belongs_to :user
  belongs_to :credit_card
  validates :txn_type, :presence => true, :inclusion => TXN_TYPES
  
  def process
    result = Braintree::CreditCard.sale(
      credit_card.token, {
        :amount => (amount_cents.to_f/100).to_s
      }
    )
    
    self.status = result.transaction.status
    self.response_code = result.transaction.processor_response_code
    
    if result.success?
      self.completed_at = Time.now
    elsif status == "processor_declined"
      self.status_explanation = result.transaction.processor_response_text
    elsif status == "gateway_rejected"
      self.status_explanation = result.transaction.gateway_rejection_reason
    else
      self.status_explanation = "Invalid : #{errors.full_messages}"
    end
  end
  
end