module Wrapr
  module FbGraph
    class Place < Wrapr::Model
      property :id, :name, :category
      property :street, :city, :state, :country, :zip, :in => :location
      property :lat, :in => :location, :as => :latitude
      property :lng, :in => :location, :as => :longitude
      
      def self.search(params, options)
        ll = Geo::Position.normalize(params)
        search = {}
        search[:center] = ll.to_s
        search[:distance] = params[:distance] || 1000
        search[:query] = params[:q] || params[:query] if params[:q] || params[:query]
        search[:type] = 'place'
        response = FbGraph::Request.get('/search', search, options)
        if response.success?
          response.payload["data"].map do |json|
            parse(json)
          end
        else
          []
        end
      end
      
      def self.find(id, options={})
        response = FbGraph::Request.get("/#{id}", {}, options)
        if response.success?
          parse(response.payload)
        else
          nil
        end
      end
    end
  end
end