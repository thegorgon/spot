require 'amatch'
module Jobs
  class PlaceDeduper
    @queue = :processing
    
    def self.perform(place_id)
      place = Place.find(place_id)
      DuplicatePlace.dedupe(place)
    end
  end
end