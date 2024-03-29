module TagHelper
  def button_tag(options={}, &block)
    tag = options.delete(:tag) || "button"
    options[:type] ||= 'submit' if tag == "button"
    show_loading = !!options.delete(:loading)
    button = "<#{tag}"
    options.each do |k, v|
      button << " #{k}=\"#{v}\""
    end
    button << ">"
    button << "<div class=\"loading\"></div>" if show_loading
    button << "<div class=\"lft\"></div>"
    button << "<div class=\"mid\"></div>"
    button << "<div class=\"rgt\"></div>"
    button << "<div class=\"btntxt\">" 
    button << capture(&block) if block
    button << "</div></#{tag}>"
    button.html_safe
  end
  
  def link_button_to(text, url, options={})
    button_tag(options.merge!(:href => url, :tag => "a")) do
      text
    end
  end
  
  def button_to(text, url, options={})
    method = options.delete(:method) || "GET"
    params = options.delete(:params)
    if method != "GET" || mobile_request?
      content_tag(:form, :action => url, :method => method, :class => "btnwrap") do
        hidden_fields = params.collect { |key, value| hidden_field_tag key, value }.join() if params
        button = button_tag(options) { text }
        (hidden_fields.to_s + button).html_safe
      end
    else
      url = url + "?#{params.to_query}" if params
      link_button_to text, url, options
    end
  end
  
  def external_js_include(file)
    content_tag(:script, "", :src => file, :type => "text/javascript")
  end
  
  def sharing(url, message, options={})
    options = {:fb => true, :twitter => true, :link => false}.merge!(options)
    content_tag(:div, :class => "clearfix sharing") do
      sharing = ""
      sharing << content_tag(:div, options[:label], :class => "label") if options[:label]
      sharing << text_field_tag("url", url, "data-mode" => "select", :class => "text light") if options[:link]
      sharing << fb_share_link(url, message) if options[:fb]
      sharing << twitter_share_link(url, message) if options[:twitter]
      sharing.html_safe
    end
  end
  
  def twitter_share_link(url, text, content=nil, options={})
    klass = content ? "twit-share-lnk" : "twit-share-btn"
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
    params = {:link => url, :name => title, :redirect_uri => root_url(:host => FBAPP[:host]), :display => "popup", :app_id => FBAPP[:id]}
    "http://www.facebook.com/dialog/send?#{params.to_query}"
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
  
  def mobile_image_tag(src, options={})
    if mobile_request?
      extension = File.extname(src)
      src = src.gsub(".#{extension}", "_mobile.#{extension}")
    end
    image_tag(src, options)
  end
  
  def mobile_img_link_to(src, url, options={})
    link_to mobile_image_tag(src, options.slice(:size, :width, :height, :border, :alt)), url, options.except(:size, :width, :height, :border, :alt)
  end
  
  def link_to_mobile_image(url, options={})
    options[:target] = "_new"
    link_to mobile_image_tag(url, options.slice(:size, :width, :height)), image_path(url), options.slice(:class, :target, :id)
  end
  
  def img_with_mobile(src, options={})
    extname = File.extname(src)
    plainsrc = src.gsub("#{extname}", "")
    size = options.delete(:size)
    msize = options.delete(:msize)
    if mobile_request?
      options[:size] = msize
      image_tag "#{plainsrc}#{msize}#{extname}", options
    else
      options[:size] = size
      image_tag "#{plainsrc}#{size}#{extname}", options
    end
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
    options[:class] << current_class if request.path == args.last || options[:current]
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