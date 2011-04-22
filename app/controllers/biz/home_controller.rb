class Biz::HomeController < Biz::BaseController
  skip_before_filter :require_account, :only => [:index]
  before_filter :require_no_account, :only => [:index]
  
  def index
  end
end