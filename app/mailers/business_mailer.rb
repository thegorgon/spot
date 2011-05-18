class BusinessMailer < ActionMailer::Base
  layout 'mailer'
  default_url_options[:host] = Rails.env.production?? "www.spot-app.com" : "www.rails.local:3000"
  FROM = "The Spot Team <noreply@spot-app.com>"
  REPLY_TO = "Julia Graham <julia@spot-app.com>"
  default :from => FROM, :reply_to => REPLY_TO
  
  def welcome(account)
    @account = account
    @email = account.email
    mail( :to => @account.email_with_name,
          'List-Unsubscribe' => "<#{email_url(:email => @email)}>",
          :subject => "Welcome to Spot for Businesses!" )
  end
  
  def contact(account, parameters)
    @account = account
    @contact = parameters[:contact]
    @subject = parameters[:subject]
    @message = parameters[:message]
    mail( :to => Rails.env.production?? "contact@spot-app.com" : "jreiss@spot-app.com",
          :reply_to => @contact,
          :subject => "New business message : #{@subject}")
  end
  
  def deal_approved(deal)
    @deal = deal
    @account = deal.business.business_account
    @email = @account.email
    @reply_to = "julia@spot-app.com"
    @phone_to = PHONE_NUMBER
    mail( :to => @account.email_with_name,
          'List-Unsubscribe' => "<#{email_url(:email => @email)}>",
          :subject => "Congratulations! Your deal has been approved for distribution." )  
  end

  def deal_rejected(deal)
    @deal = deal
    @account = deal.business.business_account
    @email = @account.email
    @reply_to = "julia@spot-app.com"
    @phone_to = PHONE_NUMBER
    mail( :to => @account.email_with_name,
          'List-Unsubscribe' => "<#{email_url(:email => @email)}>",
          :subject => "Sorry, your deal was rejected" ) 
  end
end