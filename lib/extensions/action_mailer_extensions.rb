module MailMessageExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:alias_method_chain, :deliver!, :error_protection)
  end
  
  module InstanceMethods
    def deliver_with_error_protection!
      begin
        deliver_without_error_protection!
      rescue AWS::SES::ResponseError => e
        Rails.logger.error "spot-app : captured error of type #{e.class} : #{e.message} while delivering message"
      end      
    end
  end  
end

Mail::Message.send(:include, MailMessageExtensions)