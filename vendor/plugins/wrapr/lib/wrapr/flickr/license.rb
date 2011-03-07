module Wrapr
  module Flickr
    class License < Wrapr::Model
      property :id, :name, :url
    
      def self.all
        Flickr::Request.get("photos.licenses.getInfo")
      end
    end
  end
end