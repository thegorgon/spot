class TransactionMailer < ApplicationMailer
  default :to => Proc.new { @user.try(:email_with_name) || @email }

  def invite_coming_soon(request)
    @title = "Patience is a Virtue Worth Rewarding"
    @email = request.email
    @city_name = request.city_name
    @promo_code = "REQUEST30"
    mail
  end
  
  def invitation(request, invite)
    @email = request.email
    @city = request.city
    @title = "Lucky You. You're Invited."
    @invite = invite
    @invite_url = portal_url(:mc => invite.code, :cid => @city.id, :ir => request.id)
    attachments.inline["invitation.png"] = File.read(Rails.root.join('public', 'images', 'email', 'invitation', 'youreinvited367x345.png'))
    mail
  end
  
  def notify_invites_sent(count)
    @count = count
    @email = "contact@spotmembers.com"
    @title = "Just Sent #{count} Requested Invitations Automatically"
    mail
  end

  def preview_thanks(signup)
    @signup = signup
    @email = signup.email
    @title = "Thanks for Your Interest"
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
    @title = "Spot - Event Registration"
    mail
  end

  def registration_reminder(user, code)
    @email = user.email
    @user = user
    @code = code
    @event = code.event
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