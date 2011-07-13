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
        subscription = from_braintree(braintree.subscription)
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
  
  def cancelled?
    !!cancelled_at && Time.now > cancelled_at
  end
  
  def cancel!
    unless cancelled?
      Braintree::Subscription.cancel(braintree_id)
      self.cancelled_at = Time.now
      self.expires_at = next_bill_date
      save
    end
  end
  
  def bill_period
    plan_id.split('_').last
  end
  
  def next_bill_date
    today = Time.now
    if bill_period == "annually"
      nextyear = created_at + ((today - created_at)/1.year).ceil.years
      nextbill = Date.civil(nextyear.year, created_at.month, billing_day_of_month).to_time
    elsif bill_period == "monthly"
      nextmonth = (today.month + 1).modulo(12) == 0 ? 12 : (today.month + 1).modulo(12)
      nextbill = today.day < billing_day_of_month ? 
        Date.civil(today.year, nextmonth, billing_day_of_month).to_time : 
        Date.civil(nextmonth < today.month ? today.year + 1 : today.year, nextmonth, billing_day_of_month).to_time
    end
    (expires_at.nil? || nextbill > expires_at) && nextbill
  end
end