class ApplicationMailer < ActionMailer::Base
  include AbstractController::Callbacks
  helper 'email'
  helper 'application'
  layout 'mailer'
  before_filter :set_inline_attachments
  
  default_url_options[:host] = HOSTS[Rails.env]
  default :from => "The Spot Team <spot@spotmembers.com>",
          'List-Unsubscribe' => Proc.new {  "<#{email_url(:email => @email, :key => EmailSubscriptions.passkey(@email))}>" },
          :to => Proc.new { @email },
          :subject => Proc.new { @title }
  

  private
  
  def set_inline_attachments
    add_attachment "logo.png", "logos/shdwapp80x140.png"
    add_attachment "footer.jpg", "backgrounds/emailft598x110.jpg"
  end
  
  def add_attachment(name, path)
    full_path = case path
    when String
      "#{Rails.root}/public/images/#{path}"
    when Array
      path.unshift "images"
      path.unshift "public"
      Rails.root.join(*path)
    else
      raise ArgumentError, "Invalid File Path"
    end
    
    attachments.inline[name] = File.read(full_path)    
  end
  
end