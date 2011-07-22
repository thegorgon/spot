module BizHelper  
  def biz_nextstep(biz)
    nextstep = nil

    if biz.verified? && !biz.place.image.file?
      nextstep = "We don't have an image for your business yet. Please #{link_to "upload a photo", edit_biz_business_path(biz)}."
    elsif biz.promotion_templates.active.count == 0
      nextstep = "You haven't created any promotions yet. #{link_to("Create a Promotion", calendar_biz_business_path(biz))} to start attracting 
                    Spot Members to your business."
    elsif biz.promotion_events.count == 0
      nextstep = "You haven't yet scheduled any promotions. Try the  #{link_to("easy-to-use calendar", calendar_biz_business_path(biz))} to schedule promotions
                    and start attracting Spot Members to your business during slower times."
    elsif biz.promotion_codes.issued.count == 0
      nextstep = "None of your promotions have been issued to Spot Members. Try 
                    #{twitter_share_link "http://www.spot-app.com", "Wishlist #{@business.place.name} on Spot to get updates about promotions.", "tweeting"} 
                    about your spot, 
                    #{fb_post({:name => "Wishlist #{@business.place.name} on Spot!", :caption => "Add #{@business.place.name} to your wishlist on Spot to get updates about promotions.", :url => root_url}, "posting")} 
                    about your spot on Facebook,
                    or adding a #{link_to "Spot widget", biz_widgets_path} to your website to advertise your promotions to more Spot Members."
    elsif biz.promotion_templates.active.count <= 1
      nextstep = "You've only created one promotion. Did you know that you can 
                    #{link_to("create as many promotions as you like", calendar_biz_business_path(biz))}?"
    elsif biz.promotion_events.this_week.count == 0
      nextstep = "You have no promotions scheduled this week. Use the #{link_to "calendar", calendar_biz_business_path(biz)} to 
                  #{link_to "schedule promotions", calendar_biz_business_path(biz)} at tmes that are normally slow."
    else
      nextstep = "You have #{biz.promotion_events.this_week.count} promotions scheduled for this week. 
                    Monitor your #{link_to "promotion codes", biz_business_codes_path(biz)} or 
                    #{link_to "schedule more promotions", calendar_biz_business_path(biz)}."
    end
            
    nextstep.html_safe
  end
end