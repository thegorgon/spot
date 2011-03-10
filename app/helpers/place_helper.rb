module PlaceHelper
  def external_place_url(place)
    case place
    when YelpPlace
      "http://www.yelp.com/biz/#{place.yelp_id}"
    when GooglePlace
      "http://maps.google.com/maps/place?cid=#{place.cid}"
    when GowallaPlace
      "http://www.gowalla.com/spots/#{place.gowalla_id}"      
    when FacebookPlace
      "http://www.facebook.com/pages/#{place.name.parameterize}/#{place.facebook_id}"
    when FoursquarePlace
      "http://www.foursquare.com/venue/#{place.foursquare_id}"
    else
      nil
    end
  end
end