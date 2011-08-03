class MarketingMailer < ApplicationMailer
  def spot_release(account)
    @account = account
    @email = account.email
    mail( :subject => "\"Spot\" by PlacePop - Now in the App Store" )
  end  
end