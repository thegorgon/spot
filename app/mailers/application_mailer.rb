class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  default_url_options[:host] = HOSTS[Rails.env]
  default :from => "The Spot Team <noreply@spotmembers.com>",
          'List-Unsubscribe' => Proc.new {  "<#{email_url(:email => @email)}>" },
          :to => Proc.new { @email },
          :subject => Proc.new { set_title }
  
  def set_title
    attachments.inline["logo.png"] = File.read("#{Rails.root}/public/images/logos/shdwapp80x140.png")
    attachments.inline["footer.jpg"] = File.read("#{Rails.root}/public/images/backgrounds/emailft598x110.jpg")
    @title
  end
end