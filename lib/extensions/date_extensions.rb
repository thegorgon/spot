module DateExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
    def saturday
      (sunday - 1.day)
    end    
  end
  
  module ClassMethods
  end  
end


Date.send(:include, DateExtensions)