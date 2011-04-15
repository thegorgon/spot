class AppSetting < ActiveRecord::Base
  CATEGORIES = ['timestamp']
  validates :key, :presence => true, :uniqueness => true
  validates :value, :presence => true
  validates :category, :presence => true, :inclusion => CATEGORIES

  def self.get(key)
    where(:key => key.to_s).first.try(:value)
  end
  
  def self.set!(key, value)
    record = find_or_initialize_by_key(key)
    record.value = value
    record.save!
  end
  
  def self.cache_path(page, cntrlr)
    path = case page
      when :blog
        path = [cntrlr.send(:blog_index_path), I18n.locale, get(:blog_revision) || '0'].join('/')
      when :place
        path = [cntrlr.send(:place_path, cntrlr.params[:id]), I18n.locale, AppSetting.get(:place_revision) || '0'].join('/') 
      when :sitemap
        path = [cntrlr.send(:sitemap_path), AppSetting.get(:sitemap_revision) || '0'].join('/') 
      else
        raise NotImplementedException, "Non implemented path, #{page}"
      end
    path.gsub!(/^\//, '')
    path    
  end
  
  def self.remove!(key)
    where(:key => key).delete_all
  end
  
  def category
    ActiveSupport::StringInquirer.new(self[:category])
  end
    
  def to_param
    key
  end
end