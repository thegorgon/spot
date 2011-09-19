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
      
      define_method "#{method}s" do
        [first_name, last_name]
      end

      define_method "nick#{method}" do
        if @nickname.blank?
          if first_name.present? && last_name.present?
            @nickname = [first_name, last_name.to_s.first].compact.join(" ")
            @nickname << "."
          elsif first_name.present? || last_name.present?
            @nickname = [first_name, last_name].compact.join
          elsif email.present?
            @nickname = email.split('@').first
          else
            @nickname = "noname"
          end
          @nickname.downcase!
        end
        @nickname
      end      
    end  
  end
end

Object.send(:include, ObjectExtensions)