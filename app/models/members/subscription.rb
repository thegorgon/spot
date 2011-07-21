class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :credit_card
  validates :user, :presence => true
  validates :credit_card, :presence => true
  scope :active, lambda { where(["expires_at > ?", Time.now]) }
  
  def self.subscribe(params)
    if params[:user] && params[:plan] && params[:payment]
      braintree = Braintree::Subscription.create(
        :plan_id => params[:plan],
        :payment_method_token => params[:payment].token
      )
      if braintree.success?
        subscription = synced_with(braintree.subscription)
        subscription.credit_card = params[:payment]
        subscription.user = params[:user]
        subscription
      else
        subscription = new
        subscription.errors.add(:base, "Sorry, that didn't go through. Please try again.")
      end
      subscription
    end
  end
  
  def self.synced_with(bt)
    new { |object| object.sync_with(bt) }
  end
  
  def sync_with(bt)
    self.braintree_id = bt.id
    self.status = bt.status      
    self.plan_id = bt.plan_id
    self.price_cents = (bt.price * 100).round
    self.balance_cents = (bt.balance * 100).round
    self.billing_day_of_month = bt.billing_day_of_month
    self.next_billing_date = bt.next_billing_date
    self.billing_period_start_date = bt.billing_period_start_date
    self.billing_period_end_date = bt.billing_period_end_date
  end
  
  def next_billing_date
    cancelled?? nil : self[:next_billing_date]
  end
  
  def cancelled?
    !!cancelled_at && Time.now > cancelled_at
  end
  
  def expires_at
    cancelled?? billing_period_end_date : nil
  end
  
  def cancel!
    unless cancelled?
      Braintree::Subscription.cancel(braintree_id)
      update_attribute(:cancelled_at, Time.now)
    end
  end  
end