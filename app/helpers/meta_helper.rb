module MetaHelper
  def set_page_title(value)
    @page_title = value
  end
  
  def set_spot_app_title(value)
    @spot_app_title = value
  end
  
  def page_title
    if @override_title
      @override_title
    elsif @page_title
      "#{@page_title} - Spot"
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
  
  
  def open_graph_tags
    tags = []
    if place_page?
      tags << meta_property("og:image", @place.image.url(:i640x400))
    else
      tags << meta_property("og:image", "#{IMGHOST}logos/og_image.png")
    end
    tags << meta_property("og:title", page_title)
    tags << meta_property("og:description", page_description)
    tags << meta_property("og:url", "#{request.url}")
    tags << meta_property("og:site_name", "Spot - Membership Experiences")
    tags << meta_property("fb:admins", "100000043724571")
    tags << meta_property("fb:app_id", Wrapr::FbGraph.config.client_id)
    tags.join("\n").html_safe
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
end