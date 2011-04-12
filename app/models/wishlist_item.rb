class WishlistItem < ActiveRecord::Base
  ITEM_TYPES = ["Place"]
  
  belongs_to :user
  belongs_to :item, :polymorphic => true
  belongs_to :source, :polymorphic => true
    
  validates :user_id, :presence => true, :numericality => true
  validates :item_type, :presence => true, :inclusion => ITEM_TYPES
  validates :item_id, :presence => true, :numericality => true  
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}, :if => :lat?
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}, :if => :lng
  
  after_create :enque_tweeting
  after_create :enque_propagation
  
  cattr_accessor :per_page
  @@per_page = 20
  
  scope :active, where(:deleted_at => nil)
    
  def self.activity(params={})
    params = params.symbolize_keys
    origin = Geo::LatLng.normalize(params)
    radius = params[:radius] || 50
    params[:page] = [1, params[:page].to_i].max
    finder = where(:item_type => "Place").joins("INNER JOIN places ON places.id = wishlist_items.item_id")
    finder = finder.where("#{Place.distance_sql(origin)} <= #{radius}") if origin
    finder = finder.order("id DESC")
    finder.paginate(params.slice(:page, :per_page))
  end
  
  def location=(value)
    if value = Geo::Position.from_http_header(value)
      self.lat = value.lat
      self.lng = value.lng
    end
  end
  
  def create_tweets!
    global_account = TWITTER_SETTINGS['accounts']['wishlistitems']
    Twitter.oauth_token = global_account['oauth_token']
    Twitter.oauth_token_secret = global_account['oauth_token_secret']
    begin
      Twitter.update tweet if tweet && Rails.env.production?
      true
    rescue Twitter::Forbidden => e
      false
    end
  end
  
  def tweet(options={})
    if @tweet.blank? || options[:reload]
      @tweet = "Hot on Spot: #{item.name} was just wishlisted"
      @tweet << " in" if item.city || item.region
      @tweet << " ##{item.city.gsub(' ', '').downcase}" if item.city
      @tweet << " ##{item.region_abbr.gsub(' ', '').downcase}" if item.region
      @tweet << " via @SpotTeam"
    end
    @tweet.length <= 140 ? @tweet : nil
  end
  
  def propagate!
    item_type.constantize.increment_counter(:wishlist_count, item_id)
    generate_activity! :action => "CREATE", :source => source, :public => true
    source.update_attribute(:result_id, item_id) if source.kind_of?(PlaceSearch)
    # PlaceMatch.run(item) if item.kind_of?(Place)
  end
    
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :id => id,
      :item => item.as_json(args),
      :created_at => created_at,
      :user => user.as_json(args)
    }
  end
  
  def deleted?
    deleted_at.present?
  end
  
  def destroy
    unless deleted?
      touch :deleted_at
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

  def enque_propagation
    Resque.enqueue(Jobs::Propagator, self.class.to_s, id)
  end

  def enque_tweeting
    Resque.enqueue(Jobs::WishlistTweeter, id)
  end  
end