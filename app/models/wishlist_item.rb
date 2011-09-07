class WishlistItem < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  ITEM_TYPES = ["Place"]
  
  belongs_to :user
  belongs_to :item, :polymorphic => true
  belongs_to :source, :polymorphic => true
    
  validates :user_id, :presence => true, :numericality => true
  validates :item_type, :presence => true, :inclusion => ITEM_TYPES
  validates :item_id, :presence => true, :numericality => true  
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}, :if => :lat?
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}, :if => :lng
  
  after_create :update_item_wishlist_count
  after_commit :enqueue_tweeting, :if => :new_commit?
  after_commit :enqueue_propagation, :if => :new_commit?
  
  attr_protected :deleted_at
  paginates_per 20
  
  scope :active, where(:deleted_at => nil)
  
  def self.prepare_for_nesting(records)
    preload_associations(records, [:item, :user])
    places = []
    records.map! { |r| places << r.item if r.item.kind_of?(Place); r }
    ExternalPlace.add_to(places)
  end
  
  def location=(value)
    if value = Geo::Position.from_http_header(value)
      self.lat = value.lat
      self.lng = value.lng
    end
  end
    
  def item_path
    case item
    when Place
      place_url(item, :host => HOSTS['production'])
    else
      nil
    end      
  end
  
  def tweet(options={})
    if @tweet.blank? || options[:reload]
      @tweet = "Hot on Spot: #{item.name} was just wishlisted"
      @tweet << " in" if item.city.present?
      @tweet << " ##{item.city.gsub(' ', '').gsub('-', '_').downcase}" if item.city.gsub(' ', '').present?
    end
    @tweet << " #{ShortUrl.shorten(item_path)}" if item_path.present?
    @tweet.length <= 150 ? @tweet : nil
  end
  
  def propagate!
    generate_activity! :action => "CREATE", :source => source, :public => true
    source.update_attribute(:result_id, item_id) if source.kind_of?(PlaceSearch)
    PlaceMatch.run(item) if item.kind_of?(Place)
  end
    
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :id => id,
      :item => item.as_json(:external_places => true),
      :created_at => created_at,
      :user => user.as_json(args),
      :source_type => source_type,
      :source_id => source_id
    }
  end
  
  def deleted?
    deleted_at.present?
  end
  
  def destroy
    unless deleted?
      touch :deleted_at
      User.decrement_counter(:wishlist_count, user_id)
      item_type.constantize.decrement_counter(:wishlist_count, item_id)
      generate_activity! :action => "DELETE", :public => false
    end
  end
  
  private

  def generate_activity!(extra={})
    params = {:actor => user, :activity => self, :item => item, :lat => item.lat, :lng => item.lng}
    params.merge! extra
    ActivityItem.create! params
  end

  def update_item_wishlist_count
    item_type.constantize.increment_counter(:wishlist_count, item_id)
    User.increment_counter(:wishlist_count, user_id)
  end

  def enqueue_propagation
    Rails.logger.debug("[resque] enqueue propagation from wishlist item")
    Resque.enqueue(Jobs::Propagator, self.class.to_s, id)
  end

  def enqueue_tweeting
    Rails.logger.debug("[resque] enqueue tweeting from wishlist item")
    Resque.enqueue(Jobs::Tweeter, tweet)
  end  
end