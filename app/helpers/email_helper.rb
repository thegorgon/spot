module EmailHelper
  def h1(content, options={})
    style = options[:style] || ""
    options[:style] = "#{font_style}font-size:22px;font-weight:bold;margin:5px 0;#{style}"    
    content_tag :h1, content, options
  end

  def h2(content, options={})
    style = options[:style] || ""
    options[:style] = "#{font_style}font-size:18px;font-weight:bold;margin:5px 0;#{style}"    
    content_tag :h2, content, options
  end

  def h3(content, options={})
    style = options[:style] || ""
    options[:style] = "#{font_style}font-weight:bold;margin:5px 0;#{style}"    
    content_tag :h3, content, options
  end
  
  def bold(content, options={})
    style = options[:style] || ""
    options[:style] = "#{font_style}font-weight:bold;#{style}"    
    content_tag :span, content, options
  end
  
  def hr
    tag :hr, :style => "height:1px;background:#ddd;width:450px;margin:20px auto;border:0;"
  end
  
  def font_style
    "font-family: 'Helvetica Neue', 'Helvetica', 'Lucida Grande', 'Arial', sans-serif; font-weight: 0; font-size:14px;color:#333;"
  end
  
  def table_cell(options={})
    style = options[:style] || ""
    options[:style] = "#{font_style}#{style}"    
    content_tag(:td, options) do
      yield
    end
  end
  
  def image_url(path)
    "#{IMGHOST}#{path}"
  end
  
  def paragraph_tag(options={})
    style = options[:style] || ""
    options[:style] = "margin:10px 0;padding:0;line-height:1.2em;#{style}"
    content_tag(:p, options) do
      yield
    end
  end
    
  def line_tag(options={})
    style = options[:style] || ""
    options[:style] = "padding:0;margin:0;line-height:1.5em;#{style}"
    content_tag(:p, options) do
      yield
    end
  end
  
  def table_tag(options={})
    style = options[:style] || ""
    style << "width:#{options[:width]};" if options[:width]
    style << "background:#{options[:bgcolor]};" if options[:bgcolor]
    options[:cellpadding] = 0
    options[:cellspacing] = 0
    options[:style] = "#{font_style}border-spacing:0;border-collapse:collapse;#{style}"
    content_tag(:table, options) do
      yield
    end
  end
  
  def mlink_to(*args)
    options = args.extract_options!
    (options[:style] ||="") << "color:#808080;"
    link_to *(args << options)
  end

  def mmail_to(*args)
    options = args.extract_options!
    (options[:style] ||="") << "color:#808080;"
    mail_to *(args << options)
  end
  
  def attached_img(src, options={})
    image_tag(attachments[src].url, options)
  end
  
  def attach_link_to(src, url, options={})
    link_to attached_img(src, options.slice(:size, :width, :height, :border, :alt)), url, options.except(:size, :width, :height, :border, :alt)
  end
end