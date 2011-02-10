module Flickr
  class License < Flickr::Object
    INSTANCE_KEYS = [:id, :name, :url]
    attr_accessor *INSTANCE_KEYS    
    
    def self.all
      Request.get("photos.licenses.getInfo")
    end
  end
end