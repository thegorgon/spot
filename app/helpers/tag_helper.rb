module TagHelper
  def button_tag(options={}, &block)
    options[:type] ||= 'submit'
    button = "<button"
    options.each do |k, v|
      button << " #{k}=\"#{v}\""
    end
    button << "><div class=\"btntxt\">"
    button << capture(&block) if block
    button << "</div></button>"
    button.html_safe
  end
  
  def external_js_include(file)
    content_tag(:script, "", :src => file, :type => "text/javascript")
  end
  
  def twitter_share_link(url, text, content, options={})
    klass = content ? "twitter-share-link" : "twitter-share-button"
    content ||= "&nbsp;".html_safe
    options[:class] ||= klass
    options[:target] ||= "_blank"
    options[:href] = twitter_share_url(url, text)
    share = content_tag(:a, content,options)
    share.html_safe
  end
  
  def twitter_share_url(url, text)
    params = {:url => url, :via => "spotteam", :text => text}
    "https://twitter.com/share?#{params.to_query}"
  end
  
  def fb_share_link(url, title=nil, content=nil, options={})
    klass = content ? "fb-share-link" : "fb-share-button"
    content ||= "&nbsp;".html_safe
    options[:class] ||= klass
    options[:target] ||= "_blank"
    options[:href] = fb_share_url(url, title)
    share = content_tag(:a, content, options)
    share.html_safe
  end
  
  def fb_share_url(url, title=nil)
    params = {:u => url, :title => title}
    "http://www.facebook.com/sharer.php?#{params.to_query}"
  end
  
  def fb_post(options, content=nil)
    klass = content ? "fb-post-link" : "fb-post-button"
    content ||= "&nbsp;".html_safe
    params = { 'data-fb-url' => options[:url], 
               'data-fb-name' => options[:name], 
               'data-fb-caption' => options[:caption], 
               'data-fb-description' => options[:description], 
               'data-fb-image' => options[:image] }
    share = content_tag(:a, content, params.merge!(:href => "javascript:;", :class => klass))
    share.html_safe
  end
  
  def biz_widget(business)
    content_tag(:iframe, '', :src => widget_url(:pid => business.place.id), :width => 60, :height => 26, :frameborder => 0, :marginheight => 0, :marginwidth => 0, :scrolling => "no")
  end
  
  def link_to_image(url, options={})
    options[:target] = "_new"
    link_to image_tag(url, options.slice(:size, :width, :height)), image_path(url), options.slice(:class, :target, :id)
  end
  
  def img_link_to(src, url, options={})
    link_to image_tag(src, options.slice(:size, :width, :height, :border, :alt)), url, options.except(:size, :width, :height, :border, :alt)
  end
  
  def open_graph_tags
    tags = []
    if place_page?
      tags << meta_property("og:image", @place.image.url(:i640x400))
    else
      tags << meta_property("og:image", "http://www.spot-app.com/images/logos/og_image.png")
    end
    tags << meta_property("og:title", page_title)
    tags << meta_property("og:description", page_description)
    tags << meta_property("og:url", "#{request.url}")
    tags << meta_property("og:site_name", "Spot - Never Forget a Place")
    tags << meta_property("fb:admins", "100000043724571")
    tags << meta_property("fb:app_id", Wrapr::FbGraph.config.client_id)
    tags.join("\n").html_safe
  end
  
  def spot_form_for(record, options={}, &proc)
    options[:builder] ||= Spot::FormBuilder
    display = options.delete(:display) || "faded"
    ul_id = options.delete(:ul_id)
    (options[:html] ||= {})['data-validate'] ||= "validate" unless options.delete(:validate) == false
    content_tag(:ul, form_for(record, options, &proc).html_safe, :class => "form #{display}", :id => ul_id)
  end
  
  def iphone_meta_tags
    [ meta_name("apple-mobile-web-app-capable", "yes"),
      meta_name("apple-mobile-web-app-status-bar-style", "black-translucent"),
      meta_name("viewport", "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no") ].join("\n").html_safe
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
    url = MobileApp.url_for(request_location, "itunes")
    if url
      content_tag(:div, link_to(image_tag(*args), getspot_path), :id => "itunes_store_link")
    elsif block
      capture(&block)
    else
      ""
    end
  end
  
  def js_trigger_tag
    script = <<-script
      (function() {
        var html = document.getElementsByTagName('html')[0];
        html.className = html.className.replace('no-js', 'js');
      }());
    script
    content_tag(:script, script, :type => Mime::JS)
  end
  
  def link_to_with_current(*args)
    options = args.extract_options!
    current_class = options.delete(:current_class) || "active"
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
        content << content_tag(:div, flash[:notice].to_s.html_safe, :class => "flash notice") if flash[:notice].present?
        content << content_tag(:div, flash[:error].to_s.html_safe, :class => "flash error") if flash[:error].present?
        content << content_tag(:div, "&nbsp;".html_safe, :class => "close")
        content.html_safe
      end
    end
  end
  
  def popover(content_or_options={}, options=nil, &block)
    content = block ? capture(&block) : content_or_options.to_s
    options ||= block ? content_or_options : {}
    options[:dir] ||= "none"
    klass = "popover permanent"
    klass << " #{options[:class]}" if options[:class].present?
    klass << " titled" if options[:title].present?
    klass << " arrow#{options[:dir]}"
    html_options = {:class => klass, :id => options[:id]}.merge(options[:html] || {})
    content_tag(:div, html_options) do
      content_tag(:div, :class => "hd") do
        content_tag(:div, options[:title], :class => "title") +
        content_tag(:div, '', :class => "lft") +
        content_tag(:div, '', :class => "lpad pad") +
        content_tag(:div, '', :class => "arr") +
        content_tag(:div, '', :class => "rpad pad") +
        content_tag(:div, '', :class => "rt")
      end +
      content_tag(:div, :class => "bd") do
        content_tag(:div, :class => "bgl") do 
          content_tag(:div, '', :class => 'tpad') +
          content_tag(:div, '', :class => 'arr') +
          content_tag(:div, '', :class => 'bpad')
        end +
        content_tag(:div, '', :class => "bgr") do 
          content_tag(:div, '', :class => 'tpad') +
          content_tag(:div, '', :class => 'arr') +
          content_tag(:div, '', :class => 'bpad')
        end +
        content_tag(:div, content, :class => "content")
      end +
      content_tag(:div, :class => "ft") do
        content_tag(:div, '', :class => "lft") +
        content_tag(:div, '', :class => "lpad pad") +
        content_tag(:div, '', :class => "arr") +
        content_tag(:div, '', :class => "rpad pad") +
        content_tag(:div, '', :class => "rt")
      end
    end
  end
end