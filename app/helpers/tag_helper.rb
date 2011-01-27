module TagHelper
  def button_tag(options={}, &block)
    options[:type] ||= 'submit'
    button = "<button"
    options.each do |k, v|
      button << " #{k}=\"#{v}\""
    end
    button << "><div class=\"btntxt\">"
    button << capture(&block)
    button << "</div></button>"
    button.html_safe
  end
  
  def external_js_include(file)
    content_tag(:script, "", :src => file, :type => "text/javascript")
  end
  
  def fb_share_url(url)
    share = content_tag(:a, "", :name => "fb_share", :share_url => url, :type => "button")
    share << external_js_include("http://static.ak.fbcdn.net/connect.php/js/FB.Share")  
    share.html_safe
  end

  def twitter_share_url(url, text)
    share = content_tag(:a, "", :href => "http://twitter.com/share", :class => "twitter-share-button", "data-count" => "none", "data-url" => url, "data-text" => text)
    share << external_js_include("http://platform.twitter.com/widgets.js")  
    share.html_safe
  end
  
  def open_graph_tags
    meta_tag("og:title", "Spot App")
    meta_tag("og:url", "#{request.url}")
    meta_tag("og:image", "http://www.spot-app.com/images/logos/og_image.png")
    meta_tag("og:site_name", "Spot App")
    meta_tag("og:description", "Spot App, Coming Soon")
  end
  
  def meta_tag(property, content)
    tag(:meta, :property => property, :content => content)
  end
end