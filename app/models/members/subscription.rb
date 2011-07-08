class Subscription < ActiveRecord::Base
  PLAN_ID = "eamonthly"
  belongs_to :user
  belongs_to :city
  belongs_to :payment_method
  validates :user, :presence => true
  validates :city, :presence => true
  
  scope :active, lambda { where(["expires_at > ?", Time.now]) }
  
  def self.from_redirect(result)
    user = User.from_customer(result.customer)
    custom_fields = result.customer.custom_fields
    credit_card = user.credit_cards.last
    braintree = Braintree::Subscription.create(
      :plan_id => custom_fields[:subscription_plan_id],
      :payment_method_token => credit_card.token
    )
    if braintree.success?
      subscription = from_braintree(braintree.subscription)
      subscription.user = user
      subscription.payment_method = credit_card
      subscription.city = user.city
      subscription
    else
      subscription = new
      subscription.errors.add(:base, "Sorry, that didn't go through. Please try again.")
    end
    subscription
  end
  
  def self.from_braintree(bt)
    new do |object|
      object.braintree_id = bt.id
      object.status = bt.status      
      object.plan_id = bt.plan_id
      object.price_cents = (bt.price * 100).round
      object.balance_cents = (bt.balance * 100).round
      object.billing_day_of_month = bt.billing_day_of_month
    end
  end
end