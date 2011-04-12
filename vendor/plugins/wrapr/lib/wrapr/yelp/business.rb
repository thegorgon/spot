module Wrapr
  module Yelp
    class Business < Wrapr::Model
      property :id, :name, :image_url, :url, :mobile_url, :phone,
                :display_phone, :review_count, :rating_img_url, :rating_img_url_small
      property :categories, :list => true, :model => Category
      property :location, :model => Location
      property :reviews, :list => true, :model => Review
      
      def self.search(params={}, options={})
        ll = Geo::LatLng.normalize(params)
        search = {}
        search[params[:location].present?? :cll : :ll] = ll.to_s if ll
        search[:location] = params[:location]
        search[:term] = params[:term] || params[:q] || params[:query]
        search.merge!(params.slice(:limit, :offset, :sort, :category_filter, :radius_filter, :cc, :lang, :bounds))
        response = Yelp::Request.get("/search", search, options)
        if response.success?
          response.payload["businesses"].collect do |json|
            parse(json)
          end
        else
          []
        end
      end
      
      def self.find(id, options={})
        response = Yelp::Request.get("/business/#{id}", {}, options)
        if response.success?
          Rail.logger.info("HERE : #{self}")
          parse response.payload
        else
          nil
        end
      end
    end
  end
end