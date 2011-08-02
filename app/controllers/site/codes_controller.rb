class Site::CodesController < Site::BaseController
  def show
    klass = "#{params[:type]}_code".classify.constantize rescue nil
    @code = klass.find_by_code(params[:code]) if klass && params[:code]
    render :json => {:code => @code}
  end
end