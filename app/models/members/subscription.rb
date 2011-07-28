class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :credit_card
  validates :user, :presence => true
  validates :credit_card, :presence => true
  
  class Plan < Struct.new(:cost, :period, :plan_id)
    def abbrev_period
      period == "monthly" ? "mo" : "yr"
    end
    
    def payment_summary
      "$#{cost}/#{abbrev_period}"
    end
    
    def period_name
      period == "monthly" ? "month" : "year"
    end
  end
  
  PLANS = {:venti => Plan.new(35, "annually", "ea_annually"), :grande => Plan.new(5, "monthly", "ea_monthly")}
  
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
    self.billing_day_of_month = bt.billing_day_of_month
    self.billing_period = ((Time.parse(bt.billing_period_end_date) - Time.parse(bt.billing_period_start_date))/1.month).ceil
    self.billing_starts_at = Date.parse(bt.billing_period_start_date)
  end
  
  def next_billing_date
    now = Time.now
    tdelta = now.to_i - billing_starts_at.to_i
    periods = (tdelta/billing_period.months).floor + 1
    date = now + (periods * billing_period).months
    Date.civil(date.year, date.month, billing_day_of_month)
  end
  
  def plan=(value)
    self[:plan_id] = PLANS[value.to_sym].plan_id
  end
  
  def cancelled?
    !!cancelled_at && Time.now > cancelled_at
  end
  
  def expires_at
    cancelled?? next_billing_date : nil
  end
  
  def cancel!
    unless cancelled?
      Braintree::Subscription.cancel(braintree_id)
      update_attribute(:cancelled_at, Time.now)
    end
  end  
end