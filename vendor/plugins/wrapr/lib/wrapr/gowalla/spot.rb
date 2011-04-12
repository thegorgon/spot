module Wrapr
  module Gowalla
    class Spot < Wrapr::Model
      property :id, :checkins_count, :items_count, :photos_count, :strict_radius, :name, :image_url, 
                    :lat, :lng, :trending_level, :websites, :radius_meters, :phone_number, 
                    :foursquare_id, :description, :image_url
      property :address, :model => Address
      property :creator, :model => User
      property :categories, :model => Category, :list => true, :as => :spot_categories
      
      def self.search(params={}, options={})
        ll = Geo::LatLng.normalize(params)
        search = {}
        search[:lat] = ll.lat
        search[:lng] = ll.lng
        search[:radius] = params[:radius].to_i > 0 ? params[:radius].to_i : 50
        response = Wrapr::Gowalla::Request.get('/spots', search, options)
        if response.success?
          response.payload["spots"].collect { |json| parse(json) }
        else
          []
        end
      end
    
      def self.find(id, options={})
        response = Wrapr::Gowalla::Request.get("/spots/#{id}", {}, options)
        if response.success?
          self.parse(response.payload)
        else
          nil
        end
      end
      
      def url=(value)
        self.id = value.gsub(/\/spots\/(\d+)/i, '\1')
      end      
    end
  end
end