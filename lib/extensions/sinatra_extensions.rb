module SinatraShowExceptionsExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
    def inspect
      "#<Sinatra::ShowExceptions:#{object_id}>"
    end
  end
  
  module ClassMethods
  end  
end


Sinatra::ShowExceptions.send(:include, SinatraShowExceptionsExtensions)