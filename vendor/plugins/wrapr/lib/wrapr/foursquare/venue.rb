module Wrapr
  module Foursquare
    class Venue < Wrapr::Model
      property :id, :name
      property :categories, :model => Category, :list => true
      property :location, :model => Location
      property :phone, :twitter, :in => :contact
      
      def self.search(params={})
        ll = Geo::Position.normalize(params)
        search = {}
        search[:ll] = ll.to_s
        search[:query] = params[:q] || params[:query] if params[:q] || params[:query]
        search[:limit] = params[:limit] || 10
        search[:intent] = params[:intent] || :checkin
        response = Foursquare::Request.get('/venues/search', search)
        results = []
        if response.success?
          response.payload["groups"].each do |group|
            group["items"].each do |json|
              results << parse(json)
            end
          end
        end
        results
      end
      
      def self.find(id)
        response = Wrapr::Foursquare::Request.get("/venues/#{id}")
        parse(response.payload["venue"])
      end
      
      def primary_category
        @primary_category ||= categories.find { |c| c.primary? }
      end
      
    end
  end
end