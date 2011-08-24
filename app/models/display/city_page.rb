class CityPage
  MAX_FEATURE_SIZE = 0
  
  def initialize(city)
    @city = city
    @templates = @city.upcoming_templates
  end

  def featured
    unless @featured.present?
      @featured = []
      while (@featured.length < MAX_FEATURE_SIZE) && (@templates.length > 2) do
        @featured << @templates.shift
      end
    end
    @featured.sort! { |f| f.place_id * rand }
    @featured
  end
  
  def upcoming
    @templates
  end
  
  def calendar
    unless @calendar
      events = @city.upcoming_events.group_by { |e| e.date }
      mindate = [Date.today, events.keys.min].min
      maxdate = [Date.today.end_of_month, events.keys.max].max
      @calendar = {}
      (mindate..maxdate).each do |date|
        @calendar[date] = events[date].to_a.sort { |e1, e2| e1.start_time <=> e2.start_time }
      end
    end
    @calendar
  end
end