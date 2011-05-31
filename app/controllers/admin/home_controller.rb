class Admin::HomeController < Admin::BaseController
  def index
  end
  
  def info
  end
  
  def analysis
    @analysis = Analysis.new(params)
    respond_to do |format|
      format.html
      format.js { render :json => {:analysis => @analysis} }
    end
  end  
end