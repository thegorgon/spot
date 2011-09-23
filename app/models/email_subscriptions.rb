class EmailSubscriptions < ActiveRecord::Base
  SUBSCRIPTION_FLAGS = ["deal_emails", "newsletter_emails"]
  MAX_UNSUBSCRIPTIONS = 2**31 - 1
  DEFAULT_SOURCE = "website"
  SECRET = "h0rs3s ar3 t3rr1bl3 p30pl3"
  belongs_to :user
  belongs_to :city
  after_destroy :enqueue_list_unsubscription
  after_commit :enqueue_list_subscription
  
  validates :email, :presence => true, :format => EMAIL_REGEX
  name_attribute :name
  
  serialize :data, Hash
  has_acquisition_source :count => :email_acquired
  setting_flags SUBSCRIPTION_FLAGS, :attr => "unsubscriptions", 
                                    :inverse_attr => "subscriptions",
                                    :field => "unsubscription_flags", 
                                    :method_prefix => "unsubscribed_",
                                    :inverse_method_prefix => "send_"
  

  def self.mailchimp_hook(params)
    NotifyMailer.data_msg("Mailchimp Hook", params)
    
    if params[:type] == "unsubscribe"
      # Unsubscribe this email from all emails
      if email = where(:email => params[:data][:email]).first
        email.unsubscribe_all = true
        email.save
      end
    elsif params[:type] == "cleaned" 
      # Delete this email address
      where(:email => params[:data][:email]).delete_all
    else
      # Update this email address as appropriate
      changes = {}
      email = params[:data][:email]
      
      if params[:type] == "upemail"
        email = params[:data][:old_email]
        changes[:email] = params[:data][:new_email]
      elsif params[:type] == "subscribe"
        changes[:email] = email
      end
      
      if merges = params[:data][:merges]
        city = City.find_by_slug(merges[:CITYSLUG]) if merges[:CITYSLUG].present?
        changes.merge!({
          :first_name => merges[:FNAME], 
          :last_name => merges[:LNAME], 
          :other_city => merges[:OTHERCITY], 
          :city => city
        })
      end
      changes[:unsubscription_flags] = 0 if params[:type] == 'subscribe'
      change(email, changes)
    end
    true
  end

  def self.export(file)
    require 'csv'
    CSV.open(file, 'wb') do |csv|
      csv << ["email address", "first name", "last name", "city slug", "subscriptions", "cities", "other city", "source"]
      find_each(:include => :city) do |record|
        csv << [record.email, record.first_name, record.last_name, 
                  record.city.try(:slug), record.subscriptions.collect { |s| s.humanize.titlecase }.join(','), 
                  record.city.try(:name), record.other_city, record.source]
      end
    end
  end
  
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
  
  def self.change(email, params)
    new_email = params[:email] if params[:email] && params[:email] != email
    record_with_new_email = find_by_email(new_email) if new_email
    record_with_email = find_by_email(email)
    if record_with_new_email && record_with_email
      record_with_email.destroy
      record_with_new_email.update_to_match(params)
    elsif record_with_email
      record_with_email.update_to_match(params)
    else
      record_with_email = self.ensure(params)
    end
    record_with_email
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
    if value && (!value.respond_to?(:to_i) || value.to_i > 0)
      self.unsubscription_flags = MAX_UNSUBSCRIPTIONS
    end
  end
  
  def passkey
    self.class.passkey(email)
  end
  
  def source=(value)
    self[:source] = value ? value : DEFAULT_SOURCE
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
  
  def data
    self[:data] ||= {}
  end
  
  def other_city
    self.data[:other_city]
  end
  
  def other_city=(value)
    self.data ||= {}
    self.data[:other_city] = value
    self.data_will_change!
    self.city_id = nil if value.present?
  end

  def city_name
    @city_name ||= (city.try(:name) || other_city)
    @city_name.present?? @city_name : "your city"
  end

  def update_to_match(params)
    params.each do |method, value|
      if respond_to?("#{method}=") && value
        send("#{method}=", value) 
      end
    end
    save if changed?
  end

  def subscription_change!
    enqueue_list_subscription
  end

  private

  def enqueue_list_unsubscription
    Rails.logger.debug("[resque] enqueue list unsubscription")
    Resque.enqueue(Jobs::EmailListUnsubscribe, email)
  end
  
  def enqueue_list_subscription
    Rails.logger.debug("[resque] enqueue list subscription")
    Resque.enqueue(Jobs::EmailListSubscribe, id, attribute_commited?(:email) && !new_commit? ? attribute_before_commit(:email) : nil)
  end
end