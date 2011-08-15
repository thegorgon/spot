class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  default_url_options[:host] = HOSTS[Rails.env]
  default :from => "The Spot Team <spot@spotmembers.com>",
          'List-Unsubscribe' => Proc.new {  "<#{email_url(:email => @email)}>" },
          :to => Proc.new { @email },
          "X-Sent" => Proc.new { set_x_sent },
          :subject => Proc.new { @title }
  
  def set_x_sent
    attachments.inline["logo.png"] = File.read("#{Rails.root}/public/images/logos/shdwapp80x140.png")
    attachments.inline["footer.jpg"] = File.read("#{Rails.root}/public/images/backgrounds/emailft598x110.jpg")
    Time.now.utc.to_s(:w3c)
  end
end