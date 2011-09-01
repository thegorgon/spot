class CityPage
  MAX_FEATURE_SIZE = 0
  VIEWS = ["calendar", "experiences"]
  
  def initialize(city)
    @city = city
    @templates = @city.upcoming_templates.sort { rand }
  end

  def featured
    unless @featured.present?
      @featured = []
      while (@featured.length < MAX_FEATURE_SIZE) && (@templates.length > 2) do
        @featured << @templates.shift
      end
    end
    @featured
  end
  
  def upcoming
    @templates
  end
  
  def images
    unless @images
      @calendar = nil
      calendar
    end
    @images
  end
  
  def calendar
    unless @calendar
      events = @city.upcoming_events.group_by { |e| e.date }
      mindate = [Date.today, events.keys.min].min
      maxdate = [Date.today.end_of_month, events.keys.max].max
      lastdate = mindate - 4.weeks
      @calendar = {}
      @images = {}
      @places = {}
      (mindate..maxdate).each_with_index do |date, i|
        @calendar[date] = events[date].to_a.sort { |e1, e2| e1.start_time <=> e2.start_time }
        events[date].each do |e| 
          place = e.place
          if @images[date].nil? && (@places[place.id].nil? || date.to_time - @places[place.id].to_time > 2.weeks) && (date.to_time - lastdate.to_time > 2.days)
            lastdate = date
            @places[place.id] = date
            @images[date] = place.image
          end
        end
      end
    end
    @calendar
  end
end