class AcquisitionCampaign < ActiveRecord::Base
  has_many :acquisition_sources
  validates :category, :presence => true
  validates :name, :presence => true
  
  def self.filter(params)
    finder = self
    finder.page(params[:page]).per(params[:per_page])
  end
end