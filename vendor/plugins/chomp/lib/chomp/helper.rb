module Chomp
  module Helper

    # Returns an html script tag for each of the +sources+ provided. Use symbols to specify the javascript asset groups
    # defined in config/chomp.yml. You can also pass in the filename of javascript files or full paths, just like
    # javascript_include_tag. Note, if you need the old :defaults or :all behavior, just define those as groups in the
    # configuration file.
    #
    # ==== Asset groups
    #
    # In development mode, the configuration file is parsed per request, so you can modify it without restarting the
    # server. Also, a group's glob patterns are reevaluated per request, always reflecting the current state of your
    # filesystem. One script tag is generated per file found.
    #
    # In production mode (or when Chomp.optimized is true), a single script tag is generated referencing the optimized
    # asset located in the javascripts_public_dir directory. You should set the HTTP expiration for these assets
    # far into the future to take advantage of proxy and browser caches.
    #
    def javascript_include_chomped(*sources)
      options = sources.extract_options!
      expanded_sources = []
      sources.each do |group|
        if group.is_a?(Symbol)
          if Chomp.optimized
            expanded_sources << chomp_compute_asset_path(chomp_optimized_js_assets.group(group))
          else
            expanded_sources.concat(chomp_dynamic_js_assets.group(group))
          end
        else
          expanded_sources << group
        end
      end
      javascript_include_tag(*(expanded_sources << options))
    end

    # Returns a stylesheet link tag for the sources specified as arguments. Use symbols to specify the stylesheet
    # asset groups defined in config/chomp.yml. You can modify the link attributes by passing a hash as the last
    # argument, just like stylesheet_link_tag.
    #
    # ==== Asset groups
    #
    # In development mode, the configuration file is parsed per request, so you can modify it without restarting the
    # server. Also, a group's glob patterns are reevaluated per request, always reflecting the current state of your
    # filesystem. One link tag is generated per file found.
    #
    # In production mode (or when Chomp.optimized is true), a single link tag is generated referencing the optimized
    # asset located in the stylesheets_public_dir directory. You should set the HTTP expiration for these assets
    # far into the future to take advantage of proxy and browser caches.
    #
    def stylesheet_link_chomped(*sources)
      options = sources.extract_options!
      expanded_sources = []
      sources.each do |group|
        if group.is_a?(Symbol)
          if Chomp.optimized
            expanded_sources << chomp_compute_asset_path(chomp_optimized_css_assets.group(group, request.ssl?))
          else
            expanded_sources.concat(chomp_dynamic_css_assets.group(group))
          end
        else
          expanded_sources << group
        end
      end
      stylesheet_link_tag(*(expanded_sources << options))
    end

    private

    # Compute full asset path for our cached asset, including protocol and asset host (or use the request's).
    def chomp_compute_asset_path(source)
      host = compute_asset_host(source)
      host = request.host_with_port if host.blank? # force request's host if none: full URLs defeat RAILS_ASSET_ID
      if host !~ %r{^[-a-z]+://}
        host = "#{request.protocol}#{host}"
      end
      "#{host}#{source}"
    end
  
    # Lazy-loaded dynamic assets.
    def chomp_dynamic_js_assets
      @chomp_dynamic_js_assets ||= Chomp::DynamicAssets.new(:javascript)
    end
    def chomp_dynamic_css_assets
      @chomp_dynamic_css_assets ||= Chomp::DynamicAssets.new(:stylesheet)
    end
    
    # Optimized assets used if Chomp.optimized is true.
    def chomp_optimized_js_assets
      # in multithreaded environments, there is a race condition here, but it's nothing to worry about since it's
      # harmless to instantiate multiple copies of these classes.
      @@chomp_optimized_js_assets ||= Chomp::OptimizedJSAssets.new
    end
    def chomp_optimized_css_assets
      @@chomp_optimized_css_assets ||= Chomp::OptimizedCSSAssets.new
    end
    
  end
  
end
