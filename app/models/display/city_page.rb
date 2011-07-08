class CityPage
  MAX_FEATURE_SIZE = 1
  
  def initialize(city)
    @city = city
    @templates = @city.upcoming_templates
  end

  def featured
    unless @featured.present?
      @featured = []
      while (@featured.length <= MAX_FEATURE_SIZE) && (@templates.length > 2) do
        @featured << @templates.shift
      end
    end
    @featured
  end
  
  def upcoming
    @templates
  end
end