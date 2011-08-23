class AcquisitionCampaign < ActiveRecord::Base
  has_many :acquisition_sources
  validates :category, :presence => true
  validates :name, :presence => true
  
  def self.filter(params)
    finder = self
    finder = finder.page(params[:page])
    finder = finder.per_page(params[:per_page]) if params[:per_page]
    finder.all
  end
end