class City < ActiveRecord::Base
  before_validation :set_fully_qualified_name
  scope :subscriptions_available, where("subscriptions_available > 0")

  validates :slug, :presence => true
  validates :name, :presence => true
  validates :fqn, :presence => true
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
  validates :radius, :numericality => {:greater_than => 0, :less_than => 200}, :if => :radius?
  validates :population, :numericality => {:greater_than => 0}
  validates :region, :presence => true
  validates :region_code, :presence => true
  validates :country_code, :presence => true
  validates :subscriptions_available, :presence => true, :numericality => {:greater_than_or_equal_to => 0}
  validates :subscription_count, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

  define_index do
    indexes :name, :sortable => true
    indexes :region
    indexes :country_code
  end
    
  def name_and_region
    "#{name}, #{region}".titlecase
  end
  
  def to_param
    slug
  end
    
  private
  
  def set_fully_qualified_name
    self[:fqn] ||= "#{name}, #{region}, #{country_code}"
  end

end