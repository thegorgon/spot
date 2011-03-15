class ActivityItem < ActiveRecord::Base
  belongs_to :actor, :class_name => "User"
  belongs_to :activity, :polymorphic => true
  belongs_to :item, :polymorphic => true
  
  validates :lat, :numericality => {:greater_than => -90, :less_than => 90}
  validates :lng, :numericality => {:greater_than => -180, :less_than => 180}

  acts_as_mappable
  
  def self.feed(params={})
    params = params.symbolize_keys
    origin = Geo::LatLng.normalize(params)
    radius = params[:radius] || 50
    params[:page] = [1, params[:page].to_i].max
    finder = includes(:actor)
    finder = finder.within(radius, :origin => origin) if origin
    finder = finder.order("created_at DESC")
    records = finder.paginate(:page => params[:page], :per_page => params[:per_page])
    activity_associations, item_associations = {}, {}
    records.each do |record|
      (activity_associations[record.activity_type.constantize] ||= []) << record.activity_id
      (item_associations[record.item_type.constantize] ||= []) << record.item_id
    end
    activities, items = {}, {}
    activity_associations.each { |klass, id| activities.merge! klass.where(:id => id).hash_by { |i| "#{i.class} #{i.id}" } }
    item_associations.each { |klass, id| items.merge! klass.where(:id => id).hash_by { |i| "#{i.class} #{i.id}" } }
    records.each do |record| 
      record.item = items["#{record.item_type} #{record.item_id}"]
      record.activity = activities["#{record.activity_type} #{record.activity_id}"]
    end
    records
  end  
    
  def as_json(*args)
    {
      :_type => self.class.to_s,
      :id => id,
      :activity => { 
        :_type => activity.class.to_s, 
        :id => activity.id,
        :source_type => activity.source_type,
        :source_id => activity.source_id
      },
      :item => item.as_json(args),
      :user => actor.as_json(args),
      :created_at => created_at,
    }
  end
  
end