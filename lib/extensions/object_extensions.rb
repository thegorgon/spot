module ObjectExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
  end
  
  module ClassMethods
    def name_attribute(method)
      define_method "#{method}=" do |value|
        splits = value.to_s.split(' ')
        if splits.length > 1
          self.send("last_#{method}=", splits.pop)
          self.send("first_#{method}=", splits.join(' '))
        elsif splits.length == 1
          self.send("first_#{method}=", value)
        else
          self.send("last_#{method}=", nil)
          self.send("first_#{method}=", nil)
        end
      end

      define_method "#{method}" do
        [send("first_#{method}"), send("last_#{method}")].full_compact.join(" ")
      end
    end  
  end
end

Object.send(:include, ObjectExtensions)