class ActivityItem < ActiveRecord::Base
  ACTIONS = ["CREATE", "DELETE"]
  belongs_to :actor, :class_name => "User"
  belongs_to :activity, :polymorphic => true
  belongs_to :item, :polymorphic => true
  belongs_to :source, :polymorphic => true
  
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}
  validates :action, :inclusion => ACTIONS, :presence => true

  scope :public, where("public = 1")
  scope :since, lambda { |date| where(["created_at > ?", date]) }

  acts_as_mappable
  
  def self.feed(params={})
    params = params.symbolize_keys
    origin = Geo::LatLng.normalize(params)
    radius = params[:radius] || 50
    params[:page] = [1, params[:page].to_i].max
    finder = self
    finder = finder.within(radius, :origin => origin) if origin
    finder = finder.since(params[:since]) if params[:since]
    finder = finder.order("activity_items.created_at DESC")
    records = finder.paginate(:page => params[:page], :per_page => params[:per_page], :include => [:actor, :activity, :item])
    records
  end  
    
  def action=(value)
    if value.respond_to?(:upcase)
      self[:action] = value.upcase 
    else
      self[:action] = value
    end
  end
  
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :id => id,
      :activity => { 
        :_type => activity_type, 
        :id => activity_id,
        :source_type => source_type,
        :source_id => source_id
      },
      :item => item.as_json(args),
      :user => actor.as_json(args),
      :created_at => created_at,
    }
  end
  
end