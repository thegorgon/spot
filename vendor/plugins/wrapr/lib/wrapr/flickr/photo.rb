module Wrapr
  module Flickr
    class Photo < Wrapr::Model
      acts_as_model :id, :owner, :secret, :server, :farm, :title, :ispublic, :isfriend, :isfamily
            
      def self.search(params={})
        params[:license] = params[:license].join(',') if params[:license].respond_to?(:join)
        Request.get("photos.search", params)
      end
    
      def url(options={})
        url = "http://farm#{farm}.static.flickr.com/#{server}/#{id}_#{secret}"
        if options[:size] && [:m, :s, :t, :z, :b].include?(options[:size].to_sym)
          url += "_#{options[:size]}"
        end
        url + ".jpg"
      end
    
      def source
        "flickr"
      end
    
      def owner_url
        "http://www.flickr.com/people/#{owner}/"
      end
    
      [:public, :friend, :family].each do |key|
        define_method "is#{key}=" do |value|
          instance_variable_set("@#{key}", value.to_i > 0)
        end
        define_method "#{key}?" do
          instance_variable_get("@#{key}")
        end
      end
    end
  end
end