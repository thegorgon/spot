class TransactionMailer < ApplicationMailer
  default :to => Proc.new { @user.try(:email_with_name) || @email }

  def preview_thanks(signup)
    @signup = signup
    @email = signup.email
    @title = "Thanks for Your Interest"
    mail
  end
  
  def application_thanks(application)
    @application = application
    @user = application.user
    @email = application.user.email
    @title = "Thank you for Applying"
    mail
  end

  def application_approved(application)
    @application = application
    @user = application.user
    @email = application.user.email
    @title = "Congratulations and Welcome to Spot!"
    Subscription::PLANS.each do |name, plan|
      attachments.inline["#{plan.launch_cost}per#{plan.period_name}.png"] = File.read("#{Rails.root}/public/images/assets/payment/#{plan.launch_cost}per#{plan.period_name}100x50.png")
    end
    mail
  end
  
  def password_reset(user)
    @url = edit_password_reset_url(:token => user.perishable_token)
    @user = user
    @email = user.email
    @title = "Spot Password Reset Request"
    mail
  end
  
  def registration_confirmation(user, code)
    @email = user.email
    @user = user
    @code = code
    @event = code.event
    @promotion = @event.template
    @title = "Spot - Event Registration"
    mail
  end

  def registration_reminder(user, code)
    @email = user.email
    @user = user
    @code = code
    @event = code.event
    @promotion = @event.template
    @title = "Spot - Event Reminder"
    mail
  end
  
  def expiring_membership(membership)
    @membership = membership
    @user = membership.user
    @title = "Spot Membership Expiring Soon!"
    mail
  end
end