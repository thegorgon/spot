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
  
  def link_to_image(url, options={})
    options[:target] = "_new"
    link_to image_tag(url, options.slice(:size, :width, :height)), image_path(url), options.slice(:class, :target, :id)
  end
  
  def open_graph_tags
    tags = []
    tags << meta_tag("og:title", "Spot App")
    tags << meta_tag("og:url", "#{request.url}")
    tags << meta_tag("og:image", "http://www.spot-app.com/images/logos/og_image.png")
    tags << meta_tag("og:site_name", "Spot App")
    tags << meta_tag("og:description", "Spot App, Coming Soon")
    tags << meta_tag("fb:admins", "100000043724571")
    tags.join("\n").html_safe
  end
  
  def spot_form_for(record, options={}, &proc)
    options[:builder] ||= Spot::FormBuilder
    (options[:html] ||= {})['data-validate'] ||= "validate"
    content_tag(:ul, form_for(record, options, &proc).html_safe, :class => "form")
  end
  
  def meta_tag(property, content)
    tag(:meta, :property => property, :content => content)
  end
  
  def flashes
    if flash[:notice].present? || flash[:error].present?
      content_tag(:div, :id => "flashes") do
        content = ""
        content << content_tag(:div, flash[:notice].html_safe, :class => "flash notice") if flash[:notice].present?
        content << content_tag(:div, flash[:error].html_safe, :class => "flash error") if flash[:error].present?
        content << content_tag(:div, "&nbsp;".html_safe, :class => "close")
        content.html_safe
      end
    end
  end
end