class NotifyMailer < ApplicationMailer
  layout 'notify'
  default :from => "Spot Servers <spot@spotmembers.com>",
          :to => "jesse@spotmembers.com"
         
  def msg(msg, to=nil)
    @msg = msg
    mail(:to => to || "jesse@spotmembers.com", :subject => "New Message from Spot")
  end
  
  def data_msg(title, data)
    @data = data
    mail(:subject => "New Data Message from Spot")
  end
  
  private
  
  def set_inline_attachments
  end
end