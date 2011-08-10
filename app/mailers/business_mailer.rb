class BusinessMailer < ApplicationMailer
  REPLY_TO = "Julia Graham <julia@members.com>"
  default :reply_to => REPLY_TO
  default :to => Proc.new { @account.email_with_name }
  
  def welcome(account)
    @title = "Welcome to Spot for Businesses!"
    @account = account
    @email = account.email
  end
  
  def contact(account, parameters)
    @account = account
    @contact = parameters[:contact]
    @subject = parameters[:subject]
    @message = parameters[:message]
    @title = @subject
    mail( :to => Rails.env.production?? "contact@spotmembers.com" : "jreiss@oogalabs.com",
          :reply_to => @contact,
          :subject => "New business message : #{@subject}")
  end
  
  def verified(biz)
    @account = biz.business_account
    @biz = biz
    @email = @account.email
    @reply_to = "julia@spot-app.com"
    @phone_to = PHONE_NUMBER
    mail( :subject => "Congratulations! Your business has been verified!" )  
  end
  
  def promotion_approved(promotion)
    @promotion = promotion
    @account = promotion.business.business_account
    @email = @account.email
    @reply_to = "julia@spot-app.com"
    @phone_to = PHONE_NUMBER
    mail( :subject => "Congratulations! Your promotion has been approved for distribution." )  
  end

  def promotion_rejected(promotion)
    @promotion = promotion
    @account = promotion.business.business_account
    @email = @account.email
    @reply_to = "julia@spot-app.com"
    @phone_to = PHONE_NUMBER
    mail( :subject => "Sorry, your promotion was rejected" ) 
  end
  
  def promotion_codes(business, date)
    @business = business
    @date = date
    @account = @business.business_account
    @email = @account.email
    @events = business.promotion_events.on_date(date).includes(:codes => :owner).all
    @title = "Promotion Codes for #{@date.strftime('%B %d, %Y')}"
    mail( :to => @account.email_with_name )
  end
  
  def weekly_digest(account, start_date=nil, end_date=nil)
    @account = account
    @businesses = @account.businesses
    @start_date = start_date
    @end_date = end_date
    if @start_date.nil?
      @start_date = Date.today.sunday
      @start_date = @start_date - 1.week if @start_date > Date.today
    end
    @end_date ||= @start_date + 6.days
    @email = @account.email
    @title = "Your Spot Weekly Digest"
    mail( :to => @account.email_with_name ) 
  end
end