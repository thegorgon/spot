class PlaceNote < ActiveRecord::Base
  STATUS_FLAGS = ["private", "muted"]
  PAGE_SIZE = 1000
  paginates_per PAGE_SIZE
  
  belongs_to :user
  belongs_to :place, :counter_cache => "note_count"
  validates :user, :presence => true
  validates :place, :presence => true
  
  setting_flags STATUS_FLAGS, :attr => "status_flags", 
                              :field => "status", 
                              :protected => ["muted"]
  
  after_commit :enqueue_propagation, :if => :new_commit?
  after_save :switch_activity_item_visibility

  scope :undeleted, where(:deleted_at => nil)
  scope :deleted, where("deleted_at IS NOT NULL")
  scope :visible, without_setting("private").without_setting("muted").undeleted.order("id DESC")
  scope :by_user, lambda { |u| where(:user_id => u.kind_of?(ActiveRecord::Base) ? u.id : u) }
  scope :visible_to, lambda { |u|
    if u
      where([
        "user_id = ? OR (#{without_setting_sql("private")} AND #{without_setting_sql("muted")})", 
          u.kind_of?(ActiveRecord::Base) ? u.id : u
        ]).undeleted.order("id DESC")
    else
      visible
    end
  }

  attr_protected :deleted_at  
  
  def self.filter(params={})
    finder = self
    finder = finder.where(:place_id => params[:place_id]) if params[:place_id]
    finder = finder.where(:user_id => params[:user_id]) if params[:user_id]
    finder = finder.visible_to(params[:viewer]) 
    finder = finder.page([1, params[:page].to_i].max).per(params[:per_page])
    finder
  end
  
  def self.prepare_for_nesting(records)
    preload_associations(records, [:place, :user])
    places = []
    records.map! { |r| places << r.place; r }
    ExternalPlace.add_to(places)
  end
    
  def propagate!
    generate_activity! :action => "CREATE", :public => !private? && !muted?
  end

  def destroy
    unless deleted?
      update_attribute(:deleted_at, Time.now) 
      generate_activity! :action => "DELETE", :public => false
    end
  end

  def deleted?
    !!deleted_at
  end
  
  def visible?
    !private? && !muted?
  end

  def as_json(*args)
    options = args.extract_options!
    { 
      :id => id,
      :_type => self.class.to_s,
      :place_id => place_id,
      :user => user.as_json,
      :content => content,
      :status_flags => status_flags,
      :created_at => created_at,
      :updated_at => updated_at 
    }
  end
  
  private
  
  def switch_activity_item_visibility
    if private_changed? || muted_changed?
      ActivityItem.where(:activity_type => self.class.to_s, :activity_id => self.id).update_all("public = #{visible?}")
    end
  end
  
  def generate_activity!(extra={})
    params = {:actor => user, :activity => self, :item => place, :lat => place.lat, :lng => place.lng}
    params.merge! extra
    ActivityItem.create! params
  end
  
  def enqueue_propagation
    Rails.logger.debug("[resque] enqueue propagation from place note")
    Resque.enqueue(Jobs::Propagator, self.class.to_s, id) 
  end
end