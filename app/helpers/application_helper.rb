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
end
