module Wrapr
  module Foursquare
    class Category < Wrapr::Model
      property :id, :icon, :parents, :name, :primary
    
      def primary?
        !!@primary
      end
    end
  end
end