class DealMailer < ApplicationMailer
  layout 'mailer'
  helper 'tag'

  def welcome(user)
    @user = user
    @email = user.email
    @title = "Welcome to Spot Deals!"
    mail( :reply_to => "julia@spotmembers.com",
          :subject => "You're Subscribed To Spot Deals" )
  end
end