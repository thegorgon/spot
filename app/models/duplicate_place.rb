class DuplicatePlace < ActiveRecord::Base
  SEARCH_RADIUS = 150.0 # Distance is in meters, so within 0.1 mile ~ 150 meters
  MAX_NAME_DISTANCE = 0.5
  MAX_ADDRESS_DISTANCE = 0.5
  
  cattr_accessor :per_page  
  @@per_page = 15
  
  # Statuses
  UNRESOLVED = 0
  RESOLVED = 1
  AUTORESOLVED = 2
  IGNORED = 3
  STATUSES = [UNRESOLVED, RESOLVED, AUTORESOLVED, IGNORED]
  
  belongs_to :place_1, :class_name => "Place"
  belongs_to :place_2, :class_name => "Place"
  validates :place_1, :place_2, :presence => true
  validates :place_2_id, :uniqueness => { :scope => :place_1_id }
  validates :name_distance, :address_distance, :geo_distance, :presence => true, :numericality => true
  validates :status, :inclusion => STATUSES  
  before_validation :update_total_distance
      
  def self.dedupe(place)
    if dupe = duplicate_for(place)
      dupe = DuplicatePlace.ensure(dupe)
      dupe.resolve!(dupe.preferred_canonical, :status => AUTORESOLVED) if dupe && dupe.name_distance == 0 && dupe.address_distance == 0 && dupe.geo_distance <= 0.01
    end
  end

  def self.ensure(dupe, options={})
    conditions = ["(place_1_id = ? AND place_2_id = ?) OR (place_2_id = ? AND place_1_id = ?)", dupe.place_1_id, dupe.place_2_id, dupe.place_1_id, dupe.place_2_id]
    unless where(conditions).exists?
      begin
        params = dupe.attributes.clone
        params.merge!(options)
        create!(params)
      rescue ActiveRecord::RecordNotUnique => e
        where(conditions).first
      end
    else
      where(conditions).first
    end
  end
  
  def self.duplicate_for(place)
    dupe = potential_duplicates_for(place).sort! { |d1, d2| d1.total_distance <=> d2.total_distance }.first 
    if dupe && dupe.normalized_name_distance <= MAX_NAME_DISTANCE && dupe.normalized_address_distance <= MAX_ADDRESS_DISTANCE && dupe.normalized_geo_distance <= 1
      dupe
    else
      nil
    end
  end
  
  def self.potential_duplicates_for(place)
    options = {}
    options[:field_weights] = { :name => 1, :city => 0 }
    options[:order] = "@relevance DESC, @geodist ASC"
    options[:geo] = place.to_lat_lng.ts_geo
    options[:with] = {"@geodist" => 0.0..SEARCH_RADIUS}
    options[:without] = {"sphinx_internal_id" => place.id}
    options.merge!(:star => true, :match_mode => :any)
    match_name = Geo::Cleaner.remove_extraneous_words(place.clean_name)
    name_matcher = Amatch::Sellers.new(match_name)
    addr_matcher = Amatch::Sellers.new(place.clean_address)
    potentials = []
    Place.search(place.clean_name, options).each_with_geodist do |dupe, geo_dist|
      n = Geo::Cleaner.remove_extraneous_words(dupe.clean_name)
      name_dist = name_matcher.match(n)
      addr_dist = addr_matcher.match(dupe.clean_address)
      potentials << DuplicatePlace.new( :place_1 => place, 
                                        :place_2 => dupe, 
                                        :name_distance => name_dist, 
                                        :address_distance => addr_dist, 
                                        :geo_distance => geo_dist ).freeze
    end
    potentials
  end
  
  # When auto resolving, we want to know which one is preferred so we can pick that one.
  # Auto resolving only happens with identical names, addresses and locations, so we'll look
  # at other fields.
  def preferred_canonical
    if place_1.image.file? && !place_2.image.file? #If one has an image, that's better
      place_1
    elsif place_2.image.file? && !place_1.image.file?
      place_2
    elsif place_1.wishlist_count.to_i > place_2.wishlist_count.to_i # If one is more wishlisted, that's better
      place_1
    elsif place_2.wishlist_count.to_i > place_1.wishlist_count.to_i
      place_2
    elsif place_1.id < place_2.id # If one is older, that's better
      place_1
    else
      place_2
    end
  end
  
  # Resolve this dupe. Update 
  # THIS IS WHERE THE UPDATES HAPPEN. WHEN NEW ASSOCIATIONS ARE ADDED TO PLACE
  # THEY MUST BE EXPLICITLY ADDED HERE. DYNAMIC PROGRAMMING BE DAMNED! THIS IS DELICATE!
  def resolve!(canonical, options={})
    duplicate = place_1_id == canonical.id ? place_2 : place_1
    duplicate.update_attribute(:canonical_id, canonical.id)
    duplicate.wishlist_items.update_all(:item_type => canonical.class.to_s, :item_id => canonical.id)
    GooglePlace.where(:place_id => duplicate.id).update_all(:place_id => canonical.id)
    update_attributes!(:status => options[:status] || RESOLVED, :canonical_id => canonical.id)
  end
  
  def resolved?
    status == RESOLVED
  end
  
  def ignored?
    status == IGNORED
  end
  
  def ignore!
    update_attribute(:status, IGNORED)
  end
  
  def normalized_name_distance
    # Name distance divided by the average name length
    2.0 * name_distance/(place_1.clean_name.length + place_2.clean_name.length)
  end
  
  def normalized_address_distance
    # Address distance divided by the average address length
    2.0 * address_distance/(place_1.clean_address.length + place_2.clean_address.length)
  end
  
  def normalized_geo_distance
    geo_distance/SEARCH_RADIUS
  end
    
  private
  
  def update_total_distance
    self.total_distance = normalized_name_distance + normalized_address_distance + normalized_geo_distance
  end
end