class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :city
  belongs_to :payment_method, :polymorphic => true
  validates :city, :presence => true
  validates :payment_method, :presence => true
  validates :starts_at, :presence => true
  
  scope :active, lambda { where(["starts_at < ? AND expires_at IS NULL OR expires_at > ?", Time.now, Time.now]) }

  def self.register(user, result)
    if user && result && result.success?
      custom_fields = result.customer.custom_fields
      credit_card = nil
      
      result.customer.credit_cards.each do |card|
        credit_card = user.add_credit_card(card)
      end
                  
      subscription = Subscription.subscribe :user => user, :plan => custom_fields[:subscription_plan_id], :payment => credit_card      
      membership = new(:user => user, :city => user.city, :starts_at => Time.now)
            
      if subscription.try(:save)
        user.update_attribute(:customer_id, result.customer.id)
        membership.payment_method = subscription
      end
      membership
    end
  end
  
  def cancel!
    if payment_method.kind_of?(Subscription)
      payment_method.cancel!
      update_attribute(:expires_at, payment_method.expires_at)
    end
  end  
end