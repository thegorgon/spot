class MarketingMailer < ActionMailer::Base
  layout 'mailer'
  default_url_options[:host] = HOSTS[Rails.env]
  default :from => "The Spot Team <noreply@spot-app.com>"
  
  def spot_release(account)
    @account = account
    @email = account.email
    mail( :to => @email,
          'List-Unsubscribe' => "<#{email_url(:email => @email)}>",
          :subject => "\"Spot\" by PlacePop - Now in the App Store" )
  end  
end