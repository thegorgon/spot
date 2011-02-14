module Google
  module Helper
    def google_js_api_include(options={})
      host_with_port = request.port == 80 ? request.host : request.host_with_port
      tags = javascript_include_tag("https://www.google.com/jsapi?key=#{::Google.api_key(host_with_port)}")
      (@_google_loaders ||= {}).merge!(options[:load] || {})
      load_scripts = @_google_loaders.collect { |lib, v| "google.load(\"#{lib}\", \"#{v}\");"}
      if load_scripts.present?
        tags << "\n" 
        tags << content_tag("script", load_scripts.join("").html_safe, { "type" => Mime::JS })
      end
      tags
    end

    def google_maps_api_include(options={})
      host_with_port = request.port == 80 ? request.host : request.host_with_port
      tags = javascript_include_tag("http://maps.google.com/maps/api/js?sensor=false")
      (@_google_loaders ||= {}).merge!(options[:load] || {})
      load_scripts = @_google_loaders.collect { |lib, v| "google.load(\"#{lib}\", \"#{v}\");"}
      if load_scripts.present?
        tags << "\n" 
        tags << content_tag("script", load_scripts.join("").html_safe, { "type" => Mime::JS })
      end
      tags
    end
    
    def google_place_page_url(place)
      "http://maps.google.com/maps/place?cid=#{place.cid}"
    end

    def google_load(library, version)
      @_google_loaders[library] = version
    end
    
    def google_static_map_url(mappable, options={})
      options.reverse_merge!({
        :sensor       => false,
        :size         => '250x250',
        :zoom         => 15,
        :marker_size  => 'medium',
        :marker_color => '0xff8419'
      })
      markers = {
        :size  => options.delete(:marker_size),
        :color => options.delete(:marker_color)
      }
      options[:markers] = [markers.collect { |k, v| "#{k}:#{v}" }, "#{mappable.lat},#{mappable.lng}"].join('|')
      "http://maps.google.com/maps/api/staticmap?#{options.to_query}"
    end
  end
end