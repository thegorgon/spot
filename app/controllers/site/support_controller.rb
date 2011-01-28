class Site::SupportController < Site::BaseController
  def about
    respond_to do |format|
      format.html
      format.js { default_page_render }
    end
  end
end