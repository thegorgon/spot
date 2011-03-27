class TransactionMailer < ActionMailer::Base
  layout 'mailer'
  default_url_options[:host] = "www.spot-app.com"
  default :from => "The Spot Team <noreply@spot-app.com>"
  
  def preview_thanks(signup)
    @signup = signup
    @email = signup.email
    mail( :to => @email,
          :subject => "Thanks From the Spot Team!" )
  end
end