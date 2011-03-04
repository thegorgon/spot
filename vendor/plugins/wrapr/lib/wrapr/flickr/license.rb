module Wrapr
  module Flickr
    class License < Wrapr::Model
      acts_as_model :id, :name, :url
    
      def self.all
        Flickr::Request.get("photos.licenses.getInfo")
      end
    end
  end
end