class Site::BlogController < Site::BaseController   
  layout 'site/blog'
  
  def index
    search = { :page => params[:page], :per_page => params[:per_page], :tagged => params[:tag], :search => params[:q] }
    key = "blog/items?#{search.to_query}&v=#{AppSetting.get(:blog)}"
    autoload_constants do
      @posts = Rails.cache.fetch(key, :expires_in => 1.week) do 
        Wrapr::Tumblr::Item.paginate(search)
      end
    end
    respond_to do |wants|
      wants.xml { render :layout => false }
      wants.html
    end
  end
  
  def show
    autoload_constants do
      @post = Rails.cache.fetch( "blog/items/#{params[:id]}?v=#{AppSetting.get(:blog)}", :expires_in => 1.week ) do
        Wrapr::Tumblr::Item.find(params[:id])
      end
    end
  end
  
  def refresh
    AppSetting.set!(:blog_revision, Time.now.to_i)
    redirect_to blog_index_path
  end
end