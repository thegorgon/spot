module Jobs
  class PlaceTagger
    @queue = :processing
    
    def self.perform(place_id)
      place = Place.find(place_id)
      if place.full_name.match(/\bmd\b/i)
        place.tag_with('doctor')
      end
    end
  end
end