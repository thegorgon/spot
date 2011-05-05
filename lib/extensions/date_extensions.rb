module DateExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
    def calendar_start
      month_start = self.at_beginning_of_month
      month_start - month_start.wday.days
    end
  end
  
  module ClassMethods
  end  
end


Date.send(:include, DateExtensions)