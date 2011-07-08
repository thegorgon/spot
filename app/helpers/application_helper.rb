module ApplicationHelper
  def place_page?
    @place && !@place.new_record?
  end
      
  def w3c_date(date)
    date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
  end  
  
  def page_title
    if place_page?
      [@place.name, @place.city, "Spot"].full_compact.join(" - ")
    elsif @page_title
      @page_title
    else
      "Spot - Never Forget a Place"
    end
  end
    
  def page_keywords
    keywords = ["spot", "iphone", "app", "application", "place", "wishlist"]
    if place_page?
      keywords += [@place.name.downcase, @place.city.downcase]
    elsif @page_keywords
      keywords += @keywords
    end
    keywords.join(", ")
  end
  
  def page_description
    if place_page?
      "#{@place.name} at #{@place.address} - Spot"
    elsif @page_description
      @page_description
    else
      "Spot for iPhone lets you save and quickly recall friends' recommendations 
       of places, like restaurants, bars, cafes, spas and other local shops."
    end
  end
  
  def conditionally(value, condition)
    condition ? value : nil
  end
  
  def yes_no(value)
    value ? "yes" : "no"
  end
    
  def first_or_last(items, i)
    if i == 0 && items.length == 1 
      "first last"
    elsif i == 0
      "first"
    elsif i == items.length - 1
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
end
