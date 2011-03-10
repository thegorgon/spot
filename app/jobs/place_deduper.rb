module Jobs
  class PlaceDeduper
    @queue = :processing
    
    def self.perform(place_id)
      place = Place.find(place_id)
      # PlaceMatch.run(place)      
      DuplicatePlace.dedupe(place)
    end
  end
end