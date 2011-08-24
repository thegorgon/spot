class ApplicationMailer < ActionMailer::Base
  include AbstractController::Callbacks
  layout 'mailer'
  before_filter :set_inline_attachments
  default_url_options[:host] = HOSTS[Rails.env]
  default :from => "The Spot Team <spot@spotmembers.com>",
          'List-Unsubscribe' => Proc.new {  "<#{email_url(:email => @email, :key => EmailSubscriptions.passkey(@email))}>" },
          :to => Proc.new { @email },
          :subject => Proc.new { @title }
  

  private
  
  def set_inline_attachments
    attachments.inline["logo.png"] = File.read("#{Rails.root}/public/images/logos/shdwapp80x140.png")
    attachments.inline["footer.jpg"] = File.read("#{Rails.root}/public/images/backgrounds/emailft598x110.jpg")
  end
  
end