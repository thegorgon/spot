module PlaceHelper
  def external_place_url(place)
    case place
    when ExternalPlace::YelpPlace
      "http://www.yelp.com/biz/#{place.yelp_id}"
    when ExternalPlace::GooglePlace
      "http://maps.google.com/maps/place?cid=#{place.cid}"
    when ExternalPlace::GowallaPlace
      "http://www.gowalla.com/spots/#{place.gowalla_id}"      
    when ExternalPlace::FacebookPlace
      "http://www.facebook.com/pages/#{place.name.parameterize}/#{place.facebook_id}"
    when ExternalPlace::FoursquarePlace
      "http://www.foursquare.com/venue/#{place.foursquare_id}"
    else
      nil
    end
  end
end