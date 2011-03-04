module Wrapr
  module Foursquare
    class Category < Wrapr::Model
      acts_as_model :id, :icon, :parents, :name, :primary
    
      def primary?
        !!@primary
      end
    end
  end
end