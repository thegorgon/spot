module ApplicationHelper
  def place_page?
    @place && !@place.new_record?
  end
  
  def city_page?
    @city && !@city.new_record?
  end
    
  def show_login?
    !( current_page?(account_path) && 
        current_page?(new_account_path) &&
        current_page?(new_sessions_path) )
  end
      
  def w3c_date(date)
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end  
  
  def page_title
    if @page_title
      @page_title
    elsif place_page?
      terms = [@place.name, @place.city, "Spot"]
      if @promotion
        terms.unshift(@promotion.name)
      end
      terms.full_compact.join(" - ")
    elsif city_page?
      "#{@city.name.titlecase} - Spot - Membership Experiences"
    else
      "Spot - Membership Experiences"
    end
  end
    
  def page_keywords
    keywords = ["spot", "iphone", "app", "application", "place", "wishlist", "experiences"]
    if place_page?
      keywords += [@place.name.downcase, @place.city.downcase]
    elsif city_page?
      keywords += [@city.name, @city.region]
    elsif @page_keywords
      keywords += @page_keywords
    end
    keywords.uniq.join(", ")
  end
  
  def page_description
    if @page_description
      @page_description
    elsif place_page?
      if @promotion
        "Exclusively for Spot Members. #{@promotion.name} at #{@place.name} : #{@promotion.description}"
      else
        "#{@place.name} at #{@place.address} - Spot"
      end
    else
      "Spot Members get exclusive access 
       to VIP privileges, unique promotions, and 
       unforgettable experiences at the best restaurants in town."      
    end
  end
  
  # Create a named haml tag to wrap IE conditional around a block
  # http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither
  def ie_tag(name=:body, attrs={}, &block)
    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(name, add_class('ie6', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 7]>    #{ tag(name, add_class('ie7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 8]>    #{ tag(name, add_class('ie8', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if gt IE 8]><!-->".html_safe)
    haml_tag name, attrs do
      haml_concat("<!--<![endif]-->".html_safe)
      block.call
    end
  end

  def ie_html(attrs={}, &block)
    ie_tag(:html, attrs, &block)
  end

  def ie_body(attrs={}, &block)
    ie_tag(:body, attrs, &block)
  end  
  
  def conditionally(value, condition)
    condition ? value : nil
  end
  
  def yes_no(value)
    value ? "yes" : "no"
  end
    
  def first_or_last(items, i)
    items = items.length if items.respond_to?(:length)
    if i == 0 && items == 1 
      "first last"
    elsif i == 0
      "first"
    elsif i == items - 1
      "last"
    end
  end
  
  def request_location_with_source
    if request_location
      source ||= 'param' if params[:loc]
      source ||= 'ip' if ip_location == request_location
      source ||= 'header' 
      "#{request_location} ( #{source} )"
    else
      "--"
    end
  end
  
  def phone_link(number)
    if iphone_browser?
      link_to(number, "tel:#{number.gsub(/[^\d]+/i, '')}")
    else
      number
    end
  end
  
  private
  
  def add_class(name, attrs)
    classes = attrs[:class] || ''
    classes.strip!
    classes = ' ' + classes if !classes.blank?
    classes = name + classes
    attrs.merge(:class => classes)
  end
end
