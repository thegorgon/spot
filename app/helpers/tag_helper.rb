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
    share << external_js_include("#{request.ssl? "https" : "http"}://static.ak.fbcdn.net/connect.php/js/FB.Share")  
    share.html_safe
  end

  def twitter_share_url(url, text)
    params = {:url => url, :via => "spotteam", :text => text}.to_query
    share = content_tag(:a, "&nbsp;".html_safe, :href => "https://twitter.com/share?#{params}", :target => "_blank", :class => "twitter-share-button")
    share.html_safe
  end
  
  def link_to_image(url, options={})
    options[:target] = "_new"
    link_to image_tag(url, options.slice(:size, :width, :height)), image_path(url), options.slice(:class, :target, :id)
  end
  
  def open_graph_tags
    tags = []
    if @place
      tags << meta_property("og:image", @place.image.url(:i640x400))
    else
      tags << meta_property("og:image", "http://www.spot-app.com/images/logos/og_image.png")
    end
    tags << meta_property("og:title", page_title)
    tags << meta_property("og:description", page_description)
    tags << meta_property("og:url", "#{request.url}")
    tags << meta_property("og:site_name", "Spot - Never Forget a Place")
    tags << meta_property("fb:admins", "100000043724571")
    tags.join("\n").html_safe
  end
  
  def spot_form_for(record, options={}, &proc)
    options[:builder] ||= Spot::FormBuilder
    (options[:html] ||= {})['data-validate'] ||= "validate"
    content_tag(:ul, form_for(record, options, &proc).html_safe, :class => "form")
  end
  
  def iphone_meta_tags
    [ meta_name("apple-mobile-web-app-capable", "yes"),
      meta_name("apple-mobile-web-app-status-bar-style", "black-translucent"),
      meta_name("viewport", "width=device-width, initial-scale=1.0, maximum-scale=1.0") ].join("\n").html_safe
  end
  
  def seo_tags
    [ meta_name("keywords", page_keywords),
      meta_name("description", page_description)].join("\n").html_safe
  end
  
  def meta_property(property, content)
    tag(:meta, :property => property, :content => content)
  end
  
  def meta_name(name, content)
    tag(:meta, :name => name, :content => content)
  end
  
  def itunes_store_link(*args, &block)
    url = MobileApp.url_for(request_location || current_user.try(:location), "itunes")
    if url
      content_tag(:div, link_to(image_tag(*args), getspot_path), :id => "itunes_store_link")
    elsif block
      capture(&block)
    else
      ""
    end
  end
  
  def hide_content_tag
    content_tag(:script, :type => Mime::JS) do
      "(function() {
        if ( ! /MSIE/.test(navigator.userAgent) ) {
          var hide = {'page': null, 'bg': null, 'flashes': null};
          for (var key in hide) {
            if (hide.hasOwnProperty(key)) {
              hide[key] = document.getElementById(key);
              if (hide[key]) { hide[key].style.display = 'none'; }
            }
          }
        }
      }());"
    end
  end
  
  def link_to_with_current(*args)
    options = args.extract_options!
    current_class = options.delete(:current_class) || "current"
    options[:class] ||= ""
    options[:class] << " " if options[:class].present?
    options[:class] << current_class if request.path == args.last
    args << options
    link_to *args
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