module Wrapr
  module Foursquare
    class Venue < Wrapr::Model
      acts_as_model :id, :name, :phone, :twitter, :location,
                      :categories, :primary_category,
                      :postal_code, :country
    
      def self.search(params={})
        ll = Geo::Position.normalize(params)
        search = {}
        search[:ll] = ll.to_s
        search[:query] = params[:q] || params[:query] if params[:q] || params[:query]
        search[:limit] = params[:limit] || 10
        search[:intent] = params[:intent] || :checkin
        response = Request.get('/venues/search', search)
        results = []
        if response.success?
          response.body["groups"].each do |group|
            group["items"].each do |json|
              results << parse(json)
            end
          end
        end
        results
      end
    
      def location=(value)
        @location = Location.parse(value)
      end
    
      def categories=(value)
        @categories = []
        value.to_a.each do |c|
          parsed_c = Category.parse(c)
          @categories << parsed_c
          @primary_category = parsed_c if parsed_c.primary?
        end
      end
    
      def contact=(value)
        if value
          self.phone = value['phone']
          self.twitter = value['twitter']
        end
      end

    end
  end
end