class DealMailer < ActionMailer::Base
  layout 'mailer'
  helper 'tag'
  default_url_options[:host] = HOSTS[Rails.env]
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