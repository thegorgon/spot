class PlaceNote < ActiveRecord::Base
  STATUS_FLAGS = ["private", "muted"]
  PAGE_SIZE = 1000
  
  belongs_to :user
  belongs_to :place
  validates :user, :presence => true
  validates :place, :presence => true
  
  setting_flags STATUS_FLAGS, :attr => "status_flags", 
                              :field => "status", 
                              :protected => ["muted"]
  
  after_commit :enque_propagation, :if => :new_record?

  scope :undeleted, where(:deleted_at => nil)
  scope :deleted, where("deleted_at IS NOT NULL")
  scope :visible, without_setting("private").without_setting("muted").undeleted
  scope :by_user, lambda { |u| where(:user_id => u.kind_of?(ActiveRecord::Base) ? u.id : u) }

  attr_protected :deleted_at  
  
  def self.filter(params={})
    finder = self
    finder = finder.where(:place_id => params[:place_id]) if params[:place_id]
    finder = finder.where(:user_id => params[:user_id]) if params[:user_id]
    page = [1, params[:page].to_i].max 
    per_page = params[:per_page] && params[:per_page].to_i > 1 ? params[:per_page].to_i : PAGE_SIZE
    finder = finder.visible
    finder.paginate(:page => 1, :per_page => PAGE_SIZE)
  end
  
  def propagate!
    generate_activity! :action => "CREATE", :public => !private?
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
  
  def generate_activity!(extra={})
    params = {:actor => user, :activity => self, :item => place, :lat => place.lat, :lng => place.lng}
    params.merge! extra
    ActivityItem.create! params
  end
  
  def enque_propagation
    Resque.enqueue(Jobs::Propagator, self.class.to_s, id)
  end
end