module ApplicationHelper
  def page_title
    if @place
      "Spot - Never Forget #{@place.name} in #{@place.city}".titlecase
    elsif @page_title
      @page_title
    else
      "Spot - Never Forget a Place"
    end
  end
  
  def page_keywords
    keywords = ["spot", "iphone", "app", "application", "place", "wishlist"]
    if @place
      keywords += [@place.name.downcase, @place.city.downcase]
    elsif @page_keywords
      keywords += @keywords
    end
    keywords.join(", ")
   end
  
  def page_description
    if @place
      "Spot for iPhone : #{@place.name.titlecase} at #{@place.address} in #{@place.city.titlecase}."
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
      source = ip_location ? 'ip' : 'header'
      "#{request_location} ( #{source} )"
    else
      "--"
    end
  end
end
