module ActiveSupport
  module Cache
    class Entry
      def value
        if @value
          compressed? ? Marshal.load(Zlib::Inflate.inflate(@value)) : @value
        end 
      end 
    end 
  end 
end