module Wrapr
  module Yelp
    class Category 
      attr_accessor :name, :key
      
      def self.parse(array)
        object = new
        object.name = array.first
        object.key = array.last
        object
      end
    end
  end
end