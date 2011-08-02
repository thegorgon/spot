class PaymentForm
  include ActiveModel::Validations
  extend ActiveModel::Callbacks
  include ActiveModel::Validations::Callbacks	
  
  attr_accessor :plan, :user, :tr_result, :subscription, :city, :promo_code
  before_validation :populate_fields
  validate :valid_subscription
  validate :valid_membership
  
  def initialize(params={})
    params.each do |key, value|
      send("#{key}=", value) if respond_to?(key)
    end
  end
  
  def membership
    @membership ||= Membership.new(:starts_at => Time.now)
  end

  def subscription
    @subscription ||= Subscription.new
  end

  def user=(value)
    @user = value
    if @user
      @city = @user.city
      membership.city = value.try(:city)
      membership.user = value
      subscription.user = value
      credit_card.user = value
      credit_card.cardholder_name ||= value.name
    end
  end
  
  def params=(value)
    if value && value[:promo_code]
      @promocode = PromoCode.find_by_code(value[:promo_code]) 
    end
  end
  
  def tr_data(params)
    unless @trdata
      if user.customer_id
        method = "update_customer_data"
        params[:customer_id] = user.customer_id
      else
        method = "create_customer_data"
        params[:customer] = { :email => user.email }
      end
      @trdata = Braintree::TransparentRedirect.send(method, params)
    end
    @trdata
  end
  
  def credit_card
    @credit_card ||= CreditCard.new(:expiration => Time.now + 1.year)
  end
    
  def save
    if valid?
      subscription.save
      membership.save
    end
  end
  
  private 
  
  def valid_subscription
    unless subscription.valid?
      add_our_errors(ActiveRecord::RecordInvalid, "Subscription", subscription.errors.full_messages)
    end
  end
  
  def valid_membership
    unless membership.valid?
      add_our_errors(ActiveRecord::RecordInvalid, "Membership", membership.errors.full_messages)
    end
  end
  
  def add_our_errors(klass, prefix, errorlist)
    if Rails.env.development?
      errorlist.each do |error|
        errors.add(:base, "#{prefix}: #{error}")
      end
    else
      errors.add(:base, "We messed up. We've been notified and will try to get the problem fixed as soon as possible.")
      HoptoadNotifier.notify(klass.new, { :errors => errorlist, :prefix => prefix })
    end
  end
  
  def populate_fields
    if @tr_result.try(:success?)
      custom_fields = @tr_result.customer.custom_fields
      credit_card = CreditCard.synced_with(@tr_result.customer.credit_cards.last)
      credit_card.user = user
      if credit_card.try(:save)
        @plan_id = custom_fields[:subscription_plan_id]
        self.subscription = Subscription.subscribe :user => user, 
                                                   :plan => custom_fields[:subscription_plan_id], 
                                                   :payment => credit_card,
                                                   :promo_code => custom_fields[:promo_code]
        if subscription.try(:save)
          user.update_attribute(:customer_id, @tr_result.customer.id)
          membership.payment_method = subscription
        end
      else
        add_our_errors(ActiveRecord::RecordInvalid, "Credit Card", credit_card.errors.full_messages)
      end
    elsif @tr_result
      params = @tr_result.params
      @plan_id = params[:customer][:custom_fields][:subscription_plan_id] rescue nil
      if @tr_result.credit_card_verification
        message = @tr_result.credit_card_verification.processor_response_code == "3000" ? 
          "There was a problem with the network. Please wait a moment and try again." :
          "There was a problem processing your credit card. Please check your data and try again."
        errors.add(:base, message)
      else
        add_our_errors(Braintree::BraintreeError, "Braintree", @tr_result.errors.collect { |error| error.message })
      end
    elsif @promocode
      membership.payment_method = @promocode
    end
  end
end