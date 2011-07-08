class TransactionMailer < ActionMailer::Base
  layout 'mailer'
  default_url_options[:host] = Rails.env.production?? "www.spot-app.com" : "www.rails.local:3000"
  default :from => "The Spot Team <noreply@spot-app.com>"
  
  def preview_thanks(signup)
    @signup = signup
    @email = signup.email
    mail( :to => @email,
          'List-Unsubscribe' => "<#{email_url(:email => @email)}>",
          :subject => "Thanks for your interest!" )
  end
  
  def application_thanks(application)
    @application = application
    @email = application.user.email
    @title = "Thank you for applying"
    mail( :to => @email, 
          'List-Unsubscribe' => "<#{email_url(:email => @email)}>",
          :subject => "Thank you for applying" )
  end
  
  def password_reset(user)
    @url = edit_password_reset_url(:token => user.perishable_token)
    @email = user.email
    @title = "Spot Password Reset Request"
    mail( :to => @email,
          'List-Unsubscribe' => "<#{email_url(:email => @email)}>",
          :subject => "Spot Password Reset Request" )
  end
end