module ApplicationHelper
  def page_title
    @page_title || "Spot App - Never Forget a Place"
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
