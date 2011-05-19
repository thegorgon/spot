module FixnumExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
    def pluralize(singular, plural=nil)
      "#{self || 0} " + ((self == 1 || self =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
    end
  end
  
  module ClassMethods
  end  
end


Fixnum.send(:include, FixnumExtensions)