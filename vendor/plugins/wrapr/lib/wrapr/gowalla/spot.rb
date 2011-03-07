module Wrapr
  module Gowalla
    class Spot < Wrapr::Model
      property :id, :checkins_count, :items_count, :photos_count, :categories, :strict_radius,
                    :name, :region, :locality, :image_url, :lat, :lng, :trending_level, :websites,
                    :radius_meters, :phone_number, :foursquare_id, :description, :image_url
      property :address, :model => Address
      property :creator, :model => User
      property :categories, :model => Category, :list => true, :as => :spot_categories
      
      def self.list(params={})
        ll = Geo::LatLng.normalize(params)
        search = {}
        search[:lat] = ll.lat
        search[:lng] = ll.lng
        search[:radius] = params[:radius].to_i > 0 ? params[:radius].to_i : 50
        response = Wrapr::Gowalla::Request.get('/spots', search)
        results = []
        response.payload["spots"].each { |json| results << parse(json) }
        results
      end
    
      def self.find(id)
        response = Wrapr::Gowalla::Request.get("/spots/#{id}")
        parse(response.payload)
      end
      
      def url=(value)
        self.id = value.gsub(/\/spots\/(\d+)/i, '\1')
      end
    end
  end
end