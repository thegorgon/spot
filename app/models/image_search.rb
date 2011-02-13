class ImageSearch
  def initialize(place, request)
    @place = place
    @request = request
    @source = request.params[:source].to_s
    @query = request.params[:query]
  end
  
  def results
    @results ||= {}
    case @source.to_sym
    when :flrn
      @results["Flickr : #{@place.name}"] ||= flickr_name_results.to_a
    when :flrc
      @results["Flickr : #{@place.name} #{@place.city}"] ||= flickr_name_and_city_results.to_a
    when :gon
      @results["Google : #{@place.name}"] ||= google_name_results.to_a
    when :goc
      @results["Google : #{@place.name} #{@place.city}"] ||= google_name_and_city_results.to_a
    when :flrld
      @results["Flickr : @#{@place.lat} #{@place.lng} by distance"] ||= flickr_lat_lng_by_distance.to_a
    when :flrli
      @results["Flickr : @#{@place.lat} #{@place.lng} by interestingness"] ||= flickr_lat_lng_by_interestingness.to_a
    end
    @results["Custom Query : #{@query}"] = custom_query.to_a if @query
    @results
  end
  
  private
  
  def flickr_options
    {:per_page => 10, :license => "1,2,3,4,5,6,7", :sort => "interestingness-desc"}
  end
  
  def google_options
    {:imgtype => "photo", :safe => "active", :userip => @request.remote_ip, :rsz => 8, :imgsiz => "medium|large|xlarge|xxlarge|huge"}
  end
  
  def custom_query
    google = Google::Image.search(google_options.merge(:q => "#{@query}")).to_a
    flickr = Flickr::Photo.search(flickr_options.merge(:text => "#{@query}")).to_a
    google + flickr
  end
  
  def google_name_results
    Google::Image.search(google_options.merge(:q => "#{@place.name}"))
  end

  def google_name_and_city_results
    Google::Image.search(google_options.merge(:q => "#{@place.name}, #{@place.city}"))
  end
  
  def flickr_name_results
    Flickr::Photo.search(flickr_options.merge(:text => "#{@place.name}"))
  end

  def flickr_name_and_city_results
    Flickr::Photo.search(flickr_options.merge(:text => "#{@place.name} #{@place.city}"))
  end
  
  def flickr_lat_lng_by_interestingness
    Flickr::Photo.search(flickr_options.merge(:lat => @place.lat, :lon => @place.lng))
  end
  
  def flickr_lat_lng_by_distance
    Flickr::Photo.search(flickr_options.merge(:lat => @place.lat, :lon => @place.lng).except(:sort))
  end  
end