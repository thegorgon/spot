class EmailSubscriptions < ActiveRecord::Base
  SUBSCRIPTION_FLAGS = ["deal_emails"]
  MAX_UNSUBSCRIPTIONS = 2**31 - 1
  
  SECRET = "h0rs3s ar3 t3rr1bl3 p30pl3"
  belongs_to :user
  belongs_to :city
  validates :email, :presence => true, :format => EMAIL_REGEX
  name_attribute :name
  after_commit :enqueue_list_subscription
  nested_attributes({:other_city => :string}, {:in => :data})
  setting_flags SUBSCRIPTION_FLAGS, :attr => "unsubscriptions", 
                                    :inverse_attr => "subscriptions",
                                    :field => "unsubscription_flags", 
                                    :method_prefix => "unsubscribed_",
                                    :inverse_method_prefix => "send_"
  

  def self.ensure(params)
    value = find_by_email(params[:email])
    params.delete(:city_id) if params[:city_id].to_i <= 0    
    value.update_to_match(params) if value
    begin
      value ||= create(params)
    rescue ActiveRecord::StatementInvalid => error
      raise error unless error.to_s =~ /Mysql2::Error: Duplicate/
      value = find_by_email(params[:email])
      value.update_to_match(params)
    end
    value
  end
  
  def self.passkey(email)
    digest = Digest::SHA512.hexdigest("--#{SECRET}-#{email}")
    digest[0..5]
  end

  def self.valid_passkey?(key, email)
    key && email && passkey(email) == key
  end

  def self.fetch_existing(existing, passkey)
    record = find_by_email(existing) if existing && passkey && valid_passkey?(passkey, existing)
  end
  
  def unsubscribe_all
    unsubscription_flags & MAX_UNSUBSCRIPTIONS == MAX_UNSUBSCRIPTIONS
  end

  def unsubscribe_all=(value)
    if value && value.respond_to?(:to_i) && value.to_i > 0
      self.unsubscription_flags = MAX_UNSUBSCRIPTIONS
    else
      self.unsubscription_flags = 0
    end
  end
  
  def passkey
    self.class.passkey(email)
  end

  def application_params
    { "email" => email, 
      "first_name" => first_name, 
      "last_name" => last_name, 
      "city_id" => city_id,
      "city_name" => city_name }
  end
  
  def city_id=(value)
    self[:city_id] = value
    self.data.delete(:other_city) if value.present? && value.to_i > 0
  end
  
  def other_city=(value)
    self.data[:other_city] = value
    self.city_id = nil if value.present?
  end

  def city_name
    @city_name ||= (city.try(:name) || other_city)
    @city_name.present?? @city_name : "your city"
  end

  def update_to_match(params)
    params.each do |method, value|
      send("#{method}=", value) if respond_to?("#{method}=") && value
    end
    save if changed?
  end

  private
  
  def enqueue_list_subscription
    Rails.logger.debug("[resque] enqueue list subscription")
    Resque.enqueue(Jobs::EmailListSubscribe, id, attribute_commited?(:email) && !new_commit? ? attribute_before_commit(:email) : nil)
  end
end