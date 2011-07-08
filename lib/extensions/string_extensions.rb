module StringExtensions
  TOKEN_CHARS = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
 
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
  end
  
  module ClassMethods
    def token(length, chars=nil)
      chars ||= TOKEN_CHARS
      token = ""
      1.upto(length) { |i| token << chars[rand(chars.size-1)] }
      token
    end
  end  
end


String.send(:include, StringExtensions)