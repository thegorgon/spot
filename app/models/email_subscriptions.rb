class EmailSubscriptions < ActiveRecord::Base
  SUBSCRIPTION_FLAGS = ["deal_emails"]
  belongs_to :user
  belongs_to :city
  validates :email, :presence => true, :format => EMAIL_REGEX
  name_attribute :name
  setting_flags SUBSCRIPTION_FLAGS, :attr => "unsubscriptions", 
                                    :inverse_attr => "subscriptions",
                                    :field => "unsubscription_flags", 
                                    :method_prefix => "unsubscribed_",
                                    :inverse_method_prefix => "notify_"
  

  def self.ensure(params)
    value = find_by_email(params[:email])
    begin
      value ||= create(params)
    rescue ActiveRecord::StatementInvalid => error
      raise error unless error.to_s =~ /Mysql2::Error: Duplicate/
      value = find_by_email(params[:email])
    end
    value
  end  
end