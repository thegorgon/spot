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
      tags = javascript_include_tag("https://maps.google.com/maps/api/js?sensor=false")
      (@_google_loaders ||= {}).merge!(options[:load] || {})
      load_scripts = @_google_loaders.collect { |lib, v| "google.load(\"#{lib}\", \"#{v}\");"}
      if load_scripts.present?
        tags << "\n" 
        tags << content_tag("script", load_scripts.join("").html_safe, { "type" => Mime::JS })
      end
      tags
    end
    
    def google_analytics_tag(options={})
      account_id = options[:account_id]
      content_tag(:script, :type => Mime::JS) do
        "var _gaq = _gaq || [];
        _gaq.push(['_setAccount', '#{account_id}']);
        _gaq.push(['_setDomainName', '.spot-app.com']);
        _gaq.push(['_trackPageview']);

        (function() {
          var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
          ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();"
      end.html_safe
    end
    
    def gmap_url(params)
      ll = params[:ll].to_lat_lng.to_s
      "http://maps.google.com?sll=#{ll}&q=#{params[:name]}"
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
      "https://maps.google.com/maps/api/staticmap?#{options.to_query}"
    end
  end
end