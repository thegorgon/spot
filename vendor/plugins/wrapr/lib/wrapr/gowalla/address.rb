module Wrapr
  module Gowalla
    class Address < Wrapr::Model
      property :region, :locality, :street_address, :iso3166
    
    
      def full_address
        "#{street_address} #{locality}, #{region}"
      end
    
    end
  end
end