class DealMailer < ActionMailer::Base
  layout 'mailer'
  default_url_options[:host] = Rails.env.production?? "www.spot-app.com" : "www.rails.local:3000"
  default :from => "The Spot Team <noreply@spot-app.com>"

  def welcome(user)
    @user = user
    @email = user.email
    @title = "Welcome to Spot Deals!"
    mail( :reply_to => "julia@spot-app.com",
          :to => @email,
          'List-Unsubscribe' => "<#{email_url(:email => @email)}>",
          :subject => "You're Subscribed To Spot Deals" )
  end
end