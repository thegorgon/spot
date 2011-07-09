class Site::MembershipsController < Site::BaseController
  layout 'oreo'
  
  def new
    @application = MembershipApplication.find_by_token(params[:aid])
  end
  
  def create
  end
end