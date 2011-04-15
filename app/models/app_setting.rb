class AppSetting < ActiveRecord::Base
  CATEGORIES = ['timestamp']
  validates :key, :presence => true, :uniqueness => true
  validates :value, :presence => true
  validates :category, :presence => true, :inclusion => CATEGORIES

  def self.get(key)
    where(:key => key).first.value || nil
  end
  
  def self.set!(key, value)
    record = find_or_initialize_by_key(key)
    record.value = value
    record.save!
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