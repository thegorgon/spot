class Subscription < ActiveRecord::Base
  has_acquisition_source
  belongs_to :user
  belongs_to :credit_card
  validates :user, :presence => true
  validates :credit_card, :presence => true
  before_destroy :cancel!
  
  class Plan < Struct.new(:launch_cost, :period, :plan_id)
    def abbrev_period
      period == "monthly" ? "mo" : "yr"
    end
    
    def period_name
      period == "monthly" ? "month" : "year"
    end
  end
  
  PLANS = {:venti => Plan.new(ANNUAL_PRICE, "annually", ANNUAL_PLAN), :grande => Plan.new(MONTHLY_PRICE, "monthly", MONTHLY_PLAN)}
  
  scope :active, lambda { where(["expires_at > ?", Time.now]) }
  
  def self.subscribe(params)
    promo_code = PromoCode.available.find_by_code(params[:promo_code]) if params[:promo_code]
    if params[:user] && params[:plan] && params[:payment]
      btparams = {
        :plan_id => params[:plan],
        :payment_method_token => params[:payment].token,
        :trial_duration => promo_code.try(:duration).to_i > 0 ? promo_code.duration : 1,
        :trial_period => true,
        :trial_duration_unit => "month"
      }
      braintree = Braintree::Subscription.create(btparams)
      if braintree.success?
        subscription = synced_with(braintree.subscription)
        subscription.credit_card = params[:payment]
        subscription.promo_code = promo_code.try(:code)
        subscription.user = params[:user]
        promo_code.try(:used!)
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
  
  def remote_object
    @remote_object ||= Braintree::Subscription.find(braintree_id)
  end
    
  def sync_with(bt)
    self.braintree_id = bt.id
    self.status = bt.status      
    self.plan_id = bt.plan_id
    self.price_cents = (bt.price * 100).round
    self.billing_day_of_month = bt.billing_day_of_month
    self.billing_period = bt.plan_id.split('_').last.to_i
    self.billing_starts_at = Date.parse(bt.first_billing_date)
  end
  
  def first_billing_date
    @first_billing_date ||= Date.parse(remote_object.first_billing_date)
  end
  
  def next_billing_date
    @next_billing_date ||= Date.parse(remote_object.next_billing_date)
  end
  
  def next_bill_amount
    remote_object.next_billing_period_amount
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
  
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :cancelled_at => cancelled_at,
      :next_billing_date => next_billing_date,
      :next_bill_amount => next_bill_amount,
      :first_billing_date => first_billing_date,
      :billing_day_of_month => billing_day_of_month,
      :credit_card => credit_card
    }
  end
    
end