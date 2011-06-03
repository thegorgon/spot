module BizHelper  
  def biz_completion(biz)
    percent = 0
    nextstep = nil

    if biz.place.image.file?
      percent += 10
    elsif biz.verified?
      nextstep ||= link_to "Upload a Photo", edit_biz_business_path(biz)
    end
    
    if biz.verified?
      percent += 15
    end
    
    if biz.deal_templates.active.count > 0
      percent += 20
    else
      nextstep ||= link_to("Create a Deal", calendar_biz_business_path(biz))
    end
    
    if biz.deal_events.count > 0
      percent += 20
    else
      nextstep ||= link_to("Schedule a Deal", calendar_biz_business_path(biz))
    end

    if biz.deal_codes.issued.count > 0
      percent += 15
    else
      nextstep ||= link_to "Advertise your Deals", biz_widgets_path
    end
    
    if biz.deal_templates.active.count > 1
      percent += 15
    else
      nextstep ||= link_to("Create another Deal", calendar_biz_business_path(biz))
    end
    
    nextstep ||= link_to "Schedule more Deals", calendar_biz_business_path(biz)
    
    klass = ["low", "medium", "high", "complete"][(percent/100.0 * 4).floor]
    
    percentage = content_tag(:span, "#{percent}% Complete", :class => klass)
    title = "#{percentage} : #{nextstep}".html_safe
    width = [10, percent].max
    bar = content_tag(:div, content_tag(:div, "#{percent}%".html_safe, :class => "indicator#{percent == 0 ? ' empty' : nil}", :style => "width:#{width}%;").html_safe, :class => "statusbar")
    "#{title}#{bar}".html_safe
  end
end