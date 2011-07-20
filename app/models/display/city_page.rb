class CityPage
  MAX_FEATURE_SIZE = 1
  
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
        @calendar[date] = events[date].to_a
      end
    end
    @calendar
  end
end